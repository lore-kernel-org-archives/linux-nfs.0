From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] NFS Digest, Vol 18, Issue 70 (NFS performance problems)
Date: Mon, 3 Dec 2007 15:31:39 -0500
Message-ID: <20071203203139.GF28201@fieldses.org>
References: <mailman.194659.1195581701.26582.nfs@lists.sourceforge.net>
	<BAY104-W43766F661E50E7FFCDA8EBA7F0@phx.gbl>
	<47434ED7.4010100@redhat.com> <47435049.1010800@redhat.com>
	<47445727.5090705@oracle.com> <474A3D6B.2060208@redhat.com>
	<20071126050230.GD21120@fieldses.org>
	<18254.19187.470275.538680@notabene.brown>
	<1196314230.7950.42.camel@heimdal.trondhjem.org>
	<475039E4.5070903@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: chuck.lever@oracle.com, nfs@lists.sourceforge.net,
	NeilBrown <neilb-YbfuJp6tym7X/JP9YwkgDA@public.gmane.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:51124 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750818AbXLCUcT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Dec 2007 15:32:19 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1IzHxh-0007O6-6T
	for linux-nfs@vger.kernel.org; Tue, 04 Dec 2007 07:32:17 +1100
In-Reply-To: <475039E4.5070903@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 30, 2007 at 11:27:16AM -0500, Wendy Cheng wrote:
> Trond Myklebust wrote:
>> Actually, the real problem would be dealing with something like
>> unlink('foo') followed by open('foo', O_CREAT|O_EXCL). How do you ensure
>> that a replay of those actions following a reboot is fully consistent in
>> the face of some other client attempting an open('foo', O_CREAT) at the
>> same time?
>>
>> The problem is that a number of directory operations involve exclusive
>> semantics, and so cannot be replayed. The solution to this sort of
>> problem is going to have to involve exclusive (i.e. write) directory
>> delegations to ensure that whatever transactions one client performs
>> cannot interfere with the transactions performed by another.
>>
>>   
>
> Well, a dumb question from me (borrowing Bruce's line :) ) ... even with 
> "sync" in place, when server rebooted, the RPC reply cache is gone. How 
> does linux server handle re-transmitted non-idempotent requests ?

Badly!

Somebody should figure out whether it would be possible for us to
implement persistent sessions in v4.1:

	http://www.nfsv4-editor.org/draft-17/draft-ietf-nfsv4-minorversion1-17.html#Persistence

It looks hard!

--b.

-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

