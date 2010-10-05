From: Boaz Harrosh <bharrosh@panasas.com>
Subject: use squid proxy for yum access in the lab
Date: Tue, 05 Oct 2010 18:03:00 -0400
Message-ID: <4CABA094.50100@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Steve Dickson <steved@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:17066 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756153Ab0JEWDD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Oct 2010 18:03:03 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

install squid on laptop:
[]$ yum install squid

start it:
[]$ service squid start

Then at each lab machine:
export http_proxy=http://192.168.12.228:3128

Thanks
Boaz
