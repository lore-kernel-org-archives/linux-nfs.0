Return-Path: <SRS0=XDbB=OV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,T_MIXED_ES autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32A83C67839
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 13:52:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 00AAA20839
	for <linux-nfs@archiver.kernel.org>; Wed, 12 Dec 2018 13:52:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00AAA20839
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727582AbeLLNwD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 12 Dec 2018 08:52:03 -0500
Received: from mx1.redhat.com ([209.132.183.28]:60750 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726249AbeLLNwD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 12 Dec 2018 08:52:03 -0500
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 5671F309178B;
        Wed, 12 Dec 2018 13:52:02 +0000 (UTC)
Received: from f27-node1.dwysocha.net (dhcp145-42.rdu.redhat.com [10.13.145.42])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 1FFAC1001943;
        Wed, 12 Dec 2018 13:52:00 +0000 (UTC)
From:   Dave Wysochanski <dwysocha@redhat.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/1] SUNRPC: Ensure XPRT_CONNECTED is cleared while handling TCP RST
Date:   Wed, 12 Dec 2018 08:51:56 -0500
Message-Id: <20181212135157.4489-1-dwysocha@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Wed, 12 Dec 2018 13:52:02 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Recently a customer reported a regression which was the result of a small
portion of 9b30889c548a which changed the handling of TCP_CLOSE inside
xs_tcp_state_change.  A simple reproducer was shown where an unexpected RST
injected during a simple write test would cause the NFS client to hang, a
kworker thread spinning at 100% cpu, and the only recovery was to reboot.

Upon investigation we found that the XPRT_CONNECTED bit was never cleared on
the rpc_xprt and as a result, rpc_tasks would loop around with the following
rpcdebug, which shows the rpc_xprt still has the XPRT_CONNECTED bit set even
though EPIPE (32) is coming back from the TCP layer:

kernel: RPC:    92 xprt_transmit(524516)
kernel: RPC:       xs_tcp_send_request(524516) = -32
kernel: RPC:    92 call_status (status -32)
kernel: RPC:    92 call_bind (status 0)
kernel: RPC:    92 call_connect xprt ffff8ff8abf44000 is connected
kernel: RPC:    92 call_transmit (status 0)
kernel: RPC:    92 xprt_prepare_transmit
kernel: RPC:    92 rpc_xdr_encode (status 0)
kernel: RPC:    92 marshaling UNIX cred ffff8ff835db5000
kernel: RPC:    92 using AUTH_UNIX cred ffff8ff835db5000 to wrap rpc data
kernel: RPC:    92 xprt_transmit(524516)
kernel: RPC:       xs_tcp_send_request(524516) = -32

The explanation of the above is as follows.  Prior to 9b30889c548a,
XPRT_CONNECTED was unconditionally cleared while handling TCP_CLOSE inside
xs_tcp_state_change through the following call chain:
	xs_sock_mark_closed -> xprt_disconnect_done
After the patch, while handling TCP_CLOSE, we have the following chain:
	xs_tcp_force_close -> xprt_force_disconnect
The latter will queue a work xprt_autoclose based on the XPRT_LOCKED bit.
If the xprt is locked at this point (for example due to another rpc_task in
the middle of transmission), the work won't get queued and the XPRT_CONNECTED
bit never gets cleared.

The below reproducer will trigger the problem on 4.16 - 4.19 and the 1-line
patch that follows fixes the problem.
So far I have not been able to reproduce the problem on 4.20-rc6.  However,
the patch makes handling of TCP_CLOSE consistent with that of TCP_CLOSE_WAIT
inside xs_tcp_state_change.  On the basis of consistency / correctness, and
given the impact to 4.16 - 4.19, I submit the patch that follows for 
consideration for upstream as well as stable branches of 4.16 - 4.19.


#!/bin/bash
# Reproduces NFS client hang due to sunrpc state machine spinning in 
# transmit side due to incorrect handling of XPRT_CONNECTED in presence
# of unsolicited RST.
# Tested (fails) on: 4.16, 4.17, 4.18, 4.19, 3.10.0-957.el7
#
# Author: Frank Sorenson <sorenson@redhat.com>
# From: Deependra Shekhawat <deepens@amazon.com>
# Modifications: Dave Wysochanski <dwysocha@redhat.com>
#
install_dependency() {
	/usr/bin/which $1 > /dev/null 2>&1
	[ $? -ne 0 ] && echo "Installing dependency $1" && yum install -y $2
}
install_dependency tshark wireshark
install_dependency screen screen

exports_dir=/exports2
nfsmp=/mnt/tmp
blocked_sleep_time=10
test_sleep_time1=10
test_sleep_time2=10

LOG_OVER_NET=1
# whether to log by sending to udp/514 (syslog) on HOST1 (either
#  enable remote syslog, or just add 'or udp port 514' to the packet
#  capture filter.  Goes to /dev/null, if set to 0.
#

pcap_pid=""

if [[ $LOG_OVER_NET -ne 0 ]] ; then
# probably best to be the network address of some real network, but not a real host address
# FIXME: un-comment the following in /etc/rsyslog.conf
#$ModLoad imudp
#$UDPServerRun 514
	systemctl start rsyslog
	exec 6<>/dev/udp/127.0.0.1/514
else
	exec 6<>/dev/null
fi
trap exit_cleanup EXIT
exit_cleanup() {
	iptables -D OUTPUT -p tcp -m tcp --dport 2049 -j REJECT --reject-with tcp-reset
	[[ -n $pcap_pid ]] && kill $pcap_pid
	screen -S dd_loop -X kill >/dev/null 2>&1

	rpcdebug -m rpc -c all >/dev/null
	rpcdebug -m nfs -c all >/dev/null

	exec 6>&-
}
output() {
	echo -en "$*"
#	echo -en "$0: $*" | tr -d '\n\t' | tee >(logger -t nfs_hang_test) >&6 
	echo -en "$0: $*" | tr -d '\n\t' | logger -t nfs_hang_test
	echo -en "$0: $*" | tr -d '\n\t' >&6 
}


tshark -i lo -Qw /tmp/trace.pcap tcp port 2049 or udp port 514 &
pcap_pid=$!

systemctl start nfs-server
sleep 2

output "performing setup and mount\n"
rpcdebug -m rpc -s all
rpcdebug -m nfs -s all

# Either add nfs to firewall or use 'insecure' on mount and 'noresvport' on mount
firewall-cmd --permanent --add-service=nfs
systemctl restart firewalld
mkdir -p $exports_dir
exportfs -o rw,sync,no_root_squash 127.0.0.1:$exports_dir
mkdir -p $nfsmp
mount -overs=4.1 127.0.0.1:$exports_dir $nfsmp
mkdir -p $nfsmp$exports_dir/dir



output "starting dd loop\n"
sleep 1
screen -d -m -S dd_loop /bin/bash -c "cd $nfsmp ; while true ; do date ; time dd if=/dev/zero oflag=direct of=$nfsmp$exports_dir/dir/file bs=16M count=100 2>/dev/null ; done"
output "dd loop started\n"
sleep 2


output "enabling firewall rule\n"
iptables -A OUTPUT -p tcp -m tcp --dport 2049 -j REJECT --reject-with tcp-reset
output "firewall rule added; sleeping $blocked_sleep_time\n"

sleep $blocked_sleep_time

output "removing firewall rule\n"
iptables -D OUTPUT -p tcp -m tcp --dport 2049 -j REJECT --reject-with tcp-reset
output "firewall rule removed\n"

output "sleeping $test_sleep_time1\n"
sleep $test_sleep_time1

output "checking response\n"
timeout -k 10 10 /bin/ls $nfsmp$exports_dir/dir/file >/dev/null 2>&1
res=$?

if [[ $res -eq 0 ]] ; then
	output "OK on `uname -r`: ls appears okay\n"
else
	output "WARNING on `uname -r`: ls appears hung\n"
fi

output "killing dd loop\n"
screen -S dd_loop -X kill

output "sleeping $test_sleep_time2\n"
sleep $test_sleep_time2

output "killing pcap\n"
kill $pcap_pid

output "stopping rpcdebug\n"
rpcdebug -m rpc -c all
rpcdebug -m nfs -c all

output "checking umount\n"
timeout -k 10 10 umount $nfsmp >/dev/null 2>&1
res=$?

if [[ $res -eq 0 ]] ; then
	output "TEST PASS on `uname -r`: umount ok\n"
else
	output "TEST FAIL on `uname -r`: umount hung\n"
fi

output "test complete\n"


