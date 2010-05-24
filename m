Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ns2.cypress.com ([157.95.67.5]:62247 "EHLO ns2.cypress.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757150Ab0EXWa6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 May 2010 18:30:58 -0400
Received: from corpmail.cypress.com (corpmail [157.95.1.2])
	by ns2.cypress.com (8.12.10/8.12.10) with ESMTP id o4OM6CB0002378
	for <linux-nfs@vger.kernel.org>; Mon, 24 May 2010 15:06:12 -0700 (PDT)
Received: from cobweb.mis.cypress.com (cobweb.mis.cypress.com [172.16.2.5])
	by corpmail.cypress.com (8.12.10/8.12.10) with ESMTP id o4OM66th015884
	for <linux-nfs@vger.kernel.org>; Mon, 24 May 2010 15:06:06 -0700 (PDT)
Received: from meson.design.cypress.com (meson.design.cypress.com [172.17.2.36])
	by cobweb.mis.cypress.com (8.12.11/8.12.11) with ESMTP id o4OM651l029452
	for <linux-nfs@vger.kernel.org>; Mon, 24 May 2010 15:06:05 -0700 (PDT)
Received: from lucas.design.cypress.com (lucas [172.17.14.37])
	by meson.design.cypress.com (8.9.3+Sun/8.9.3) with ESMTP id PAA28957
	for <linux-nfs@vger.kernel.org>; Mon, 24 May 2010 15:06:05 -0700 (PDT)
Received: from lucas.design.cypress.com (localhost [127.0.0.1])
	by lucas.design.cypress.com (8.13.8/8.13.8) with ESMTP id o4OM64Z1030480
	for <linux-nfs@vger.kernel.org>; Mon, 24 May 2010 15:06:04 -0700
Message-ID: <4BFAF84C.5040003@cypress.com>
Date: Mon, 24 May 2010 15:06:04 -0700
From: Risto Bell <reb@cypress.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: FW: Yet Another NFS Performance Question
References: <A17A76CF549D0F4EBC38AD7AA7A3CBDA7675EA69FD@MUFASA.ts.odu.edu>
In-Reply-To: <A17A76CF549D0F4EBC38AD7AA7A3CBDA7675EA69FD@MUFASA.ts.odu.edu>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Kumar, Amit H. wrote:
> Context: NFSv3:
> I would like to get your input on the following NFS stats recorded on our server. I have read up this thread(http://www.opensubscriber.com/message/nfs@lists.sourceforge.net/7833588.html) describing the contents of /proc/net/rpc/nfsd;
>
> My Numbers are really high, for 'th' line in nfsd file...
> ...
> # uname -a
> Linux nfs3-io-0-3.local 2.6.18-53.1.14.el5 #1 SMP Wed Mar 5 11:37:38 EST 2008 x86_64 x86_64 x86_64 GNU/Linux
 > ...

Your clients (if close to CENTOS5.1: upgrade) may be hitting:

   https://bugzilla.redhat.com/show_bug.cgi?id=321111
   http://bugs.centos.org/view.php?id=2635

Client caching is impaired, hits server VERY much harder, more
often than necessary (slow down on clients, network, and server).

To demo: loop stat of a mounted dir's file that does not exist,
the deeper (dir depth) the better.

---------------------------------------------------------------
This message and any attachments may contain Cypress (or its
subsidiaries) confidential information. If it has been received
in error, please advise the sender and immediately delete this
message.
---------------------------------------------------------------

