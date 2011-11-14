Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e9.ny.us.ibm.com ([32.97.182.139]:59057 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755014Ab1KNVrZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Nov 2011 16:47:25 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Mon, 14 Nov 2011 16:47:24 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pAELlLXY235756
	for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2011 16:47:21 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pAELlKQx011090
	for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2011 16:47:21 -0500
Date: Mon, 14 Nov 2011 16:47:20 -0500
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Cc: NeilBrown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC 0/7] Volatile Filehandle Client-side Support
Message-ID: <20111114214720.GB3747@Gelgoog.pok.ibm.com>
References: <1321052673-22171-1-git-send-email-treinish@linux.vnet.ibm.com>
 <1321056809.8733.2.camel@lade.trondhjem.org>
 <20111112144953.GA3740@infradead.org>
 <20111113145400.6c7a9be3@notabene.brown>
 <20111113180633.GA4084@Gelgoog.pok.ibm.com>
 <CAGue13qMD24f0FRAknyqsj9=rzDvmqPMUb0rf_dDRhyk5SXKHQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAGue13qMD24f0FRAknyqsj9=rzDvmqPMUb0rf_dDRhyk5SXKHQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 14, 2011 at 10:09:58AM +0100, Tigran Mkrtchyan wrote:
> > The other thought was that this could be used for migration/replication
> > between file synced servers. So, if we wanted to switch/move to another server where
> > the file names were the same but all the inode numbers were different you could use
> > this to refresh the invalid file handles on the new server.
> 
> If my scec reading is correct, then spec does not enforce you to use
> the same file handles on redirected server. This is of course you you
> want to return NFS4ERR_MOVED.

What I was referring to was Section 6.4:

   Filehandles for filesystems that are replicated or migrated generally
   have the same semantics as for filesystems that are not replicated or
   migrated.  For example, if a filesystem has persistent filehandles
   and it is migrated to another server, the filehandle values for the
   filesystem will be valid at the new server.

So in the case where you sync the files between 2 servers using some type of
file transfer (for example, rsync) the file handles will be different because 
all the inode numbers would be different between the machines. You can use 
VFH to get around this though, the same section states:

   If the bit FH4_VOL_MIGRATION is set in the fh_expire_type attribute,
   the client must treat the volatile filehandle as if the server had 
   returned the NFS4ERR_FHEXPIRED error.  At the migration or replication
   event in the presence of the FH4_VOL_MIGRATION bit, the client will not
   present the original or old volatile filehandle to the new server.
   The client will start its communication with the new server by
   recovering its filehandles using the saved file names.

So assuming you synced the files so that the paths are the same on the 2 servers,
by having the servers just return FH4_VOL_MIGRATION for FH_EXPIRE_TYPE, you could
then use VFH recovery to lookup the current file handles for the new server.

-Matt Treinish

