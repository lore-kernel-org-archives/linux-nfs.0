Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp107.prem.mail.sp1.yahoo.com ([98.136.44.62]:43890 "HELO
	smtp107.prem.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751243Ab0CIFt3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Mar 2010 00:49:29 -0500
Message-ID: <4B95E167.40306@schaufler-ca.com>
Date: Mon, 08 Mar 2010 21:49:27 -0800
From: Casey Schaufler <casey@schaufler-ca.com>
To: Brad Boyer <flar@allandria.com>
CC: James Morris <jmorris@namei.org>, linux-nfs@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-fsdevel@vger.kernel.org,
        Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH 0/6][v4][RFC] NFSv3: implement extended attribute protocol
 (XATTR)
References: <alpine.LRH.2.00.1002261457420.25193@tundra.namei.org> <alpine.LRH.2.00.1003082122340.6314@tundra.namei.org> <20100309035932.GA14237@cynthia.pants.nu>
In-Reply-To: <20100309035932.GA14237@cynthia.pants.nu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Brad Boyer wrote:
> On Mon, Mar 08, 2010 at 09:42:06PM +1100, James Morris wrote:
>   
>> Since the last version, I've incorporated feedback to add a new top-level 
>> xattr namespace "nfsd", for storing client-origin xattrs on the server.  
>> Support for the new namespace has been implemented on ext3 for testing 
>> purposes.
>>
>> Access to this namespace locally requires CAP_SYS_ADMIN, and it is not 
>> accessible over the wire.  Note that there is still potential for 
>> confusion between local and remote users, e.g.
>>
>> $ setfattr -n user.foo -v bar file.txt
>>
>> on an NFS mounted fs will create an xattr on the server called 
>> nfsd.user.foo, and then if the user logs in locally, they will not see the 
>> xattr at all.  Similarly, if they create xattrs locally, they will not be 
>> exported via XATTR.
>>
>> Comments welcome.
>>     
>
> I personally think it's a bad idea to not map regular user xattr values
> directly to what is local to the server. One common thing I've seen in
> many places is to have local disks on various servers exported over
> NFS to other servers, but the intent is that the user shouldn't care
> which server physically hosts the storage. In this case, you want the
> data to appear the same regardless of the use or non-use of NFS. In
> this sort of situation, one system will see different data than the
> others for the same files with the same access level. One possible
> option would be to make it configurable, kind of like root_squash.
>   

Another is to NFS mount the filesystem back on to the server,
in which case James' scheme works just dandy. It's a trick that
I've used more than once in the Unix world for this exact purpose.
Of course you have to arrange your mount points in advance with
malice aforethought, but that's likely something you're used to
by now.

> 	Brad Boyer
> 	flar@allandria.com
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>   

