From: Jeff Layton <jlayton@redhat.com>
Subject: Re: (no subject)
Date: Thu, 2 Aug 2007 11:45:54 -0400
Message-ID: <20070802114554.552c3407.jlayton@redhat.com>
References: <6efae230.53ea6361.46b186ac.d4e1b@o2.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGcsB-00022f-Bw
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 08:46:03 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IGcsE-00052j-KC
	for nfs@lists.sourceforge.net; Thu, 02 Aug 2007 08:46:03 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l72FjtsO011028
	for <nfs@lists.sourceforge.net>; Thu, 2 Aug 2007 11:45:55 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l72Fjt0Q023852
	for <nfs@lists.sourceforge.net>; Thu, 2 Aug 2007 11:45:55 -0400
Received: from tleilax.poochiereds.net (vpn-14-120.rdu.redhat.com
	[10.11.14.120])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with SMTP id l72FjsJO031618
	for <nfs@lists.sourceforge.net>; Thu, 2 Aug 2007 11:45:54 -0400
In-Reply-To: <6efae230.53ea6361.46b186ac.d4e1b@o2.pl>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 02 Aug 2007 09:24:28 +0200
Piotr Kandziora <raveen@tlen.pl> wrote:

> Server NFS: 192.168.0.166
> client 1: 192.168.0.169
> client 2: 192.168.0.183
> 
> showmount output on server:
> # showmount -a
> All mount points on hostname:
> *:/aa
> *:/bb
> 192.168.0.169:*
> 192.168.0.183:*
> 
> # cat /var/lib/nfs/rmtab
> 192.168.0.183:*:0x00000001
> *:/aa:0x00000002
> 192.168.0.169:*:0x00000002
> *:/bb:0x00000002
> 
> client 1:
> # mount|grep 166
> 192.168.0.166:/aa on /mnt/tmp0 type nfs (rw,addr=192.168.0.166)
> 192.168.0.166:/bb on /mnt/tmp1 type nfs (rw,addr=192.168.0.166)
> 
> client 2:
> # mount|grep 166
> 192.168.0.166:/aa on /mnt/tmp0 type nfs
> (rw,vers=3,rsize=32768,wsize=32768,hard,proto=udp,timeo=7,retrans=3,addr=192.168.0.166)
> 
> On client 1 there are mounted two shares (aa and bb), on client 2 only one share (aa).
> 
> My questions are:
> 
> How to get information about mounted shares on concrete clients from showmount or other command?
> 

This info will never be reliable -- see the notes on rmtab in
rpc.mountd(8).

> What is meaning of asterisks in showmount output?

The nfs-utils rmtab handling code was recently fixed a few months ago.
You're likely running older code that's inserting these bogus entries
into the rmtab for each mount.

-- 
Jeff Layton <jlayton@redhat.com>

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
