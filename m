Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f182.google.com ([209.85.212.182]:52954 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760524Ab3JPMs7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Oct 2013 08:48:59 -0400
Received: by mail-wi0-f182.google.com with SMTP id ez12so685660wid.9
        for <linux-nfs@vger.kernel.org>; Wed, 16 Oct 2013 05:48:58 -0700 (PDT)
Message-ID: <525E8B38.20602@primarydata.com>
Date: Wed, 16 Oct 2013 15:48:56 +0300
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: bfields@redhat.com, NFS list <linux-nfs@vger.kernel.org>
Subject: Re: nfs4_file usage
References: <20131015211445.GA23636@infradead.org> <525E2C5C.4020104@primarydata.com> <20131016064649.GB28758@infradead.org> <525E5228.80200@primarydata.com> <20131016085117.GA21665@infradead.org> <525E840D.3040509@primarydata.com> <20131016123315.GA29454@infradead.org>
In-Reply-To: <20131016123315.GA29454@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-16 15:33, Christoph Hellwig wrote:
> On Wed, Oct 16, 2013 at 03:18:21PM +0300, Benny Halevy wrote:
>> The nfs4.1 layout stateid is like any other stateid (open/lock/deleg)
>> but it's life time is a bit different as it is not descending from the
>> open stateid (though the protocol requires the client to use it
>> to acquire the first layout for the file) and it is released via
>> either LAYOUTRETURN or CLOSE (in the "return_on_close" case).
>> The rules here are different enough from open/lock/deleg stateids that
>> pnfsd needs special code to handle the management of the actual layout state
>> under the layout stateid and manipulate it accordingly.
> 
> I'm not primarily ocnfused about the protocol even if that isn't all
> that clear either.  I'm more worried about the code in and around
> nfs4_find_create_layout_stateid.  I have looked a bit deeper into it
> and I think the main problem is that struct nfs4_stid isn't refcounted
> by itself, which really confused me expecting nfsd4_lookup_stateid
> to return a reference to it.
> 

True.  That is likely to change with the state lock elimination project
where a stateid would get refcounted once found and its pointer is returned to
the caller.
