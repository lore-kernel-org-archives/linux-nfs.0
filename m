Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:41938 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756860Ab3J2BA3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 21:00:29 -0400
Message-ID: <526F0893.5030700@redhat.com>
Date: Mon, 28 Oct 2013 21:00:03 -0400
From: Ric Wheeler <rwheeler@redhat.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Anand Avati <aavati@redhat.com>,
        Dr Fields James Bruce <bfields@redhat.com>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        Dickson Steve <steved@redhat.com>
Subject: Re: XATTRs in NFS?
References: <20131028180838.GG31322@fieldses.org> <526EC3F7.3090601@gmail.com> <526EFFCC.2060506@redhat.com> <18F0636D-7CE0-42C1-9249-325DF69516D4@netapp.com>
In-Reply-To: <18F0636D-7CE0-42C1-9249-325DF69516D4@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/28/2013 08:49 PM, Myklebust, Trond wrote:
> On Oct 28, 2013, at 8:22 PM, Anand Avati <aavati@redhat.com> wrote:
>
>> On 10/28/2013 01:07 PM, Ric Wheeler wrote:
>>> On Mon, Oct 28, 2013 at 02:00:58PM -0400, Ric Wheeler wrote:
>>>> On 10/28/2013 01:49 PM, Myklebust, Trond wrote:
>>>>> On Oct 28, 2013, at 12:15 PM, Christoph Anton Mitterer
>>>> <calestyo@scientia.net> wrote:
>>>>>> On Mon, 2013-10-28 at 11:40 -0400, Ric Wheeler wrote:
>>>>>>> Then you end up with large directories and an extra name per inode
>>>> that needs to
>>>>>>> be stored and extra lookups for each file when you do a whole file
>>>> system crawl.
>>>>>>> Certainly not as easy as adding and xattrs with that information :)
>>>>>> And I think there's another reason why it wouldn't work...
>>>>>>
>>>>>> Imagine I change my system to encode what should be XATTRs in hardlink
>>>>>> pseudo files...
>>>>>>
>>>>>> If I have such pair locally e.g. on my ext4:
>>>>>> /foo/bar/actual/file
>>>>>> /meta/<SHA512 identifier>.2342348324
>>>>>>
>>>>>> And now move/copy the file via the network to the archive, I'd have to
>>>>>> copy both files (which is really annoying), and I'd guess the inode
>>>>>> coupling would get los (and at least the name wouldn't fit anymore).
>>>>>>
>>>>>> So the whole thing is IMHO not even a workaround.
>>>>> OK. So you're going to do XATTRs for us?
>>>>>
>>>>> Trond
>>>> Now that pNFS is perfect and labeled NFS has made it upstream, I
>>>> think that Steve D must be looking for something to keep him busy :)
>>> I agree with Trond that we first really need good evidence about exactly
>>> who wants this and why.
>>>
>> Some reasons why XATTRs in NFS could be useful w/ glusterfs:
>>
>> - glusterfs exposes data locality through virtual extended attributes. One could do a getxattr("filename", "glusterfs.pathinfo") and get a parsable response about which servers store what parts and copies of the file. Such a mechanism is already used to implement Hadoop plugins for example (Hadoop plugin internally mounts gluster through FUSE where xattrs work). In some use-cases we really want to use NFS and still retain the ability to expose data locality through virtual xattrs, but lack of xattr support limits that possibility.
>>
>> - gluster implements a "merkel tree" like inode attribute called "xtime" which is the recursive max mtime of all files/dirs in a subtree, maintained in real-time on all dirs. This is an extremely handy and powerful feature for implementing backups. This xtime is both stored as an xattr and exposed as an xattr. Users who chose to mount gluster through NFS protocol are giving up access this feature which is available only through xattrs.
>>
>> - A very similar recursive function also provided by gluster is real-time size of dir subtrees, also exposed as extended attributes. For e.g a user instead of doing "du -hs /mnt/gluster/some/subdir" can instead do "getfattr -n glusterfs.quota.size /mnt/gluster/some/dir" and get instantaneous results. Again such a feature is not available for users mounting through NFS because of the lack of generic xattrs.
>>
>> - A lot of our users have asked many times for the ability to use existing NFS servers as "gluster bricks" - because they have paid a ton of money and/or have a lot of data in there and do not want to "move it out". A major roadblocker for such a use case is the lack of xattr support. Gluster stores a lot of metadata in xattrs and therefore avoids having a "metadata server" (for e.g it stores details about which of the copies of a file/dir is fresh and stale in xattrs of that inode, it stores "hash ranges" of directories as xattrs on the directory inode, etc.) If only NFS mounts supported storing of these xattrs, we could support pre-existing NFS volumes as gluster bricks.
>>
>> These are just some reasons on how implementing xattrs in NFS can be useful to one project.
>>
>> It would be interesting to see how the server can control the caching behavior of such xattrs. For ex some of the (virtual) xattrs are better not cached by the client ever.
>>
>> Avati
> ..and here is a perfect example of exactly what is wrong with xattrs. You're describing a private syscall interface, not a data storage format.
>
> Trond

What Avati described is having an application store user defined attributes in a 
file in a standard way - pretty much every local file system does this.  I don't 
get the private syscall interface comment or the need to re-argue a battle that 
was waged and lost effectively *years* ago :)

Ric

