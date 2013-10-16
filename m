Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f171.google.com ([74.125.82.171]:39478 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932406Ab3JPMSY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Oct 2013 08:18:24 -0400
Received: by mail-we0-f171.google.com with SMTP id t60so610521wes.30
        for <linux-nfs@vger.kernel.org>; Wed, 16 Oct 2013 05:18:23 -0700 (PDT)
Message-ID: <525E840D.3040509@primarydata.com>
Date: Wed, 16 Oct 2013 15:18:21 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: bfields@redhat.com, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: nfs4_file usage
References: <20131015211445.GA23636@infradead.org> <525E2C5C.4020104@primarydata.com> <20131016064649.GB28758@infradead.org> <525E5228.80200@primarydata.com> <20131016085117.GA21665@infradead.org>
In-Reply-To: <20131016085117.GA21665@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-16 11:51, Christoph Hellwig wrote:
> On Wed, Oct 16, 2013 at 11:45:28AM +0300, Benny Halevy wrote:
>> I'm reluctant about the layout stateids as it uses common hashing data structs
>> locking infrastructure, and code with all other nfsd4 stateids.
> 
> The layout stateids are another thing that confuses me in the current
> pnfs code.  Depending on what we find the generic state id might be
> embedded into the layout stateid or they might be separate, but there
> don't seem to be clear rules on how to deal with freeing things in the
> later case.  I haven't brought this up because I didn't dig deep into it
> enough, but it's for sure more than confusing.
> 

The nfs4.1 layout stateid is like any other stateid (open/lock/deleg)
but it's life time is a bit different as it is not descending from the
open stateid (though the protocol requires the client to use it
to acquire the first layout for the file) and it is released via
either LAYOUTRETURN or CLOSE (in the "return_on_close" case).
The rules here are different enough from open/lock/deleg stateids that
pnfsd needs special code to handle the management of the actual layout state
under the layout stateid and manipulate it accordingly.

>> We can have a similar hash table for pnfsd_inode similar to nfs4_file
> 
> Yes, that was the plan.
> 
>> Note that nfs4_file is also per inode, not per file as might be reflected from its name.
>> Maybe moving it nfs4state.c also warrants renaming it to something more accurate.
> 
> Yes, it should have an inode instead of file in the name, and it really
> should be nfsd4_ prefix instead of using the client namespace. Given
> that it's open/locking specific I'm not even sure that name should be
> that generic.

Yeah, the server naming conventions are confusing and in many cases
conflicting with client names (file names, data types, functions, etc.)

> 
>> And while there, change file_hashval to hash on i_ino rather than the inode ptr.
> 
> That's a bad idea.  i_ino is 32-bit only while many NFS-exported
> filesystems have 64-bit inode numbers.  Hashing on kernel pointers
> genetrally is a fairly good idea, and we do it for the inode in other
> places, too.
> 

How many bits in the kernel address space are unique?
I am under the impression that they'd differ mostly in their least significant bits anyway.
Regardless, if it works well now then no reason to change it.
