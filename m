Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24981 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750760Ab3KDRzT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Nov 2013 12:55:19 -0500
Message-ID: <5277DFBB.1010901@RedHat.com>
Date: Mon, 04 Nov 2013 12:56:11 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "dpquigl@davequigley.com" <dpquigl@davequigley.com>
Subject: Re: [PATCH] nfs: set security label when revalidating inode
References: <1383389838-1858-1-git-send-email-jlayton@redhat.com> <C85EF88C-B4F8-484C-A00D-5A86ACB61C10@netapp.com> <5277BAFB.9070109@RedHat.com> <48054582-1F6A-4A27-AE62-C9B0AE8F9619@netapp.com>
In-Reply-To: <48054582-1F6A-4A27-AE62-C9B0AE8F9619@netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 04/11/13 11:03, Myklebust, Trond wrote:
> 
> On Nov 4, 2013, at 10:19, Steve Dickson <SteveD@redhat.com> wrote:
> 
>>
>>
>> On 02/11/13 22:23, Myklebust, Trond wrote:
>>>
>>> On Nov 2, 2013, at 6:57, Jeff Layton <jlayton@redhat.com> wrote:
>>>
>>>> Currently, we fetch the security label when revalidating an inode's
>>>> attributes, but don't apply it. This is in contrast to the readdir()
>>>> codepath where we do apply label changes.
>>>
>>> OK. Why should we not just throw out the code that fetches the security label here?
>> Looking back at the original code (aka David's tree), the label was being set 
>> in  nfs_refresh_inode() after the nfs_refresh_inode_locked() call:
>>
>> int nfs_refresh_inode(struct inode *inode, struct nfs_fattr *fattr, struct nfs4_label *label)
>> {
>>    int status;
>>
>>    if ((fattr->valid & NFS_ATTR_FATTR) == 0)
>>        return 0;
>>    spin_lock(&inode->i_lock);
>>    status = nfs_refresh_inode_locked(inode, fattr, label);
>>    spin_unlock(&inode->i_lock);
>>    if (nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL)) {
>>        if (label && !status)
>>            nfs_setsecurity(inode, fattr, label);
>>    }
>>
>>    return status; 
>> }
>>
>> This code chunk got remove when I removed the setting of labels from 
>> all the original places they were being set (aka access, commits, etc).
> 
>> There is an outstanding bug on how the client is not recognizing the
>> changing of a label.. So this patch will probably fix that bug…
> 
> I understood the question to be about why the client isn’t recognising changes 
> that are made on the server. Are you saying that we’re failing to set the label 
> correctly when the client itself changes it? That would be a bug under the 
> existing caching rules.
Yes... On app changes the label via nfs4_xattr_set_nfs4_label() 
but another app won't see the change since the label was not updated
by the getattr... Now would the label eventually get updated? 
Probably... through a lookup or open or something... 

Basically this is a bug in my forward port of Dave's code.  

Now I think you are questioning does the label even need
to be part of the getattr... As I just explained, I think 
so... How else will change be noticed?

steved.

> 
>>>
>>> IOW: what is the caching model that is being implemented in this patch; 
>>> is it just “fetch label at random intervals” or is there real method to the madness?
>> There is no caching model per say... I really don't think there needs to be
>> one... Labels are a client only thing meaning the server is not expect to
>> change the label and an application is expect to set them... So if there
>> is any caching to be done it should be done by the application, not the 
>> filesystem... IMHO...  
> 
> Right, but this argues against the need for polling.
> 
> Cheers,
>   Trond
> 
> 
> --
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
