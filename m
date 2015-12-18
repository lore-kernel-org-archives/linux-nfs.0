Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48830 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932099AbbLRInp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Dec 2015 03:43:45 -0500
Subject: Re: possible bug in nfs-kernel-server
To: Omar Walid Llorente <omar@dit.upm.es>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        =?UTF-8?Q?administraci=c3=b3n_del_centro_de_c=c3=a1lculo_del_dit?=
	<cdc@dit.upm.es>
References: <564EFE51.90105@dit.upm.es>
 <20151121091824.71ab1f6b@tlielax.poochiereds.net>
 <b259acd35a93bd2293630c35b8761e6b@dit.upm.es> <566954D6.7090508@dit.upm.es>
 <5669702D.50402@redhat.com> <20151210144434.GB12544@fieldses.org>
 <566EF4E4.60809@dit.upm.es> <5672A78D.4090303@redhat.com>
 <20151218003722.GA1452@us.ibm.com>
From: Soumya Koduri <skoduri@redhat.com>
Message-ID: <5673C73C.2030109@redhat.com>
Date: Fri, 18 Dec 2015 14:13:40 +0530
MIME-Version: 1.0
In-Reply-To: <20151218003722.GA1452@us.ibm.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/18/2015 06:07 AM, Malahal Naineni wrote:
> IIRC, permission checks are done in open(). write/read syscalls should
> NOT do much access checks (at least based on POSIX). This is why once an
> open is done, you remove permissions for that process, but it should
> still be able to read/write based on the open flags it did when it
> opened the file.
>
> I don't know all the details of this defect, but gluster seems to be
> doing what it is supposed to do.
>
Right. Thanks for the correction. I assumed the behavior should be same 
for both OPEN+WRITE vs CREATE+WRITE in the below scenario. But looks 
like (from 'man creat')  the open() call that creates a read-only file 
may well return a read/write file descriptor, which is the reason the 
following WRITE can succeed.

Thanks,
Soumya


> Regards, Malahal.
>
> Soumya Koduri [skoduri@redhat.com] wrote:
>> As mentioned by Bruce, GlusterFS doesn't have owner-override rule
>> except for setattr.
>>
>> I did few experiments to check why this test case passes on plain
>> glusterfs fuse mount & NFS-Ganesha but fails with kernel-NFS.
>>
>> NFS-Ganesha (for most of the FSALs) seem to be passing the actual
>> request credentials to the back-end filesystem only for
>> CREATE(-like) and UNLINK fops. For all the remaining fops, it does
>> the access check at its end and then perform the operation with root
>> credentials. That's the reason WRITE succeeded in your case as
>> NFS-Ganesha (like kernel-NFS) skipped the access check if the
>> request caller_uid proved to be the file's owner.
>>
>> In case of native GlusterFS FUSE mount, there is no OPEN fop
>> involved. WRITE is performed on the fd returned by CREATE. And
>> strangely GlusterFS seem to be doing certain access checks only
>> during OPEN but not for WRITE (this seems like a bug and probably
>> needs to be fixed in Gluster).
>>
>> Thanks,
>> Soumya
>>
>> On 12/14/2015 10:27 PM, Omar Walid Llorente wrote:
>>>
>>> Thank you Bruce, others, for the responses. I send attached a complete
>>> capture of the issue, including the glusterfs transactions.
>>>
>>> Hope this helps to clear where may it be...
>>>
>>> Omar
>>>
>>> El 10/12/15 a las 15:44, J. Bruce Fields escribió:
>>>> On Thu, Dec 10, 2015 at 05:59:33PM +0530, Soumya Koduri wrote:
>>>>>
>>>>> On 12/10/2015 04:02 PM, Omar Walid Llorente wrote:
>>>>>> Hi, Jeff, Bruce, finally I got some time to get the capture of the nfs
>>>>>> packets (you can find them in attached file nfs-problem-nks.pcap.zip).
>>>>>> Sorry for being so late.
>>>>>>
>>>>>> What I did was the following:
>>>>>>
>>>>>> 1st) Create the RO file:
>>>>>> cdc@l056:~/prueba-git$ rm -f kk.txt 444.txt; echo "prueba" > 444.txt;
>>>>>> chmod 444 444.txt;
>>>>>>
>>>>>> 2nd) Init the capture:
>>>>>> root@l056:~# tcpdump -i eth2 -w /tmp/nfs.pcap -s 512 port 2049
>>>>>> tcpdump: listening on eth2, link-type EN10MB (Ethernet), capture size
>>>>>> 512 bytes
>>>>>>
>>>>> GlusterFS protocol is added to wireshark from version 1.8.0 [1]. It
>>>>> may be helpful to see what GlusterFS operations are being processed
>>>>> as part of NFS WRITE call (which has failed in this case).
>>>>>
>>>>> Could you please try taking the packet trace on the machine where
>>>>> NFS server is running (without filtering out based on the port
>>>>> number).
>>>>>
>>>>> Also I tried out the same test on Fedora22 machine, but haven't run
>>>>> into any issue. What are the fuse mount options you have used to
>>>>> mount gluster volume?
>>>> Oh, I think this is a simple problem (but maybe hard to fix).  The
>>>> capture shows NFSv3 traffic like:
>>>>
>>>>     CREATE -> OK
>>>>     SETATTR (mode set to 0400) -> OK
>>>>     WRITE -> NFS3ERR_ACCES
>>>>
>>>> That write would succeed locally (because the mode doesn't matter to a
>>>> local application that already holds the file open).  It would fail over
>>>> NFSv3, which doesn't know about the open--except that there's a hack for
>>>> this case: NFSv3 servers allow IO operations to ignore the mode, if the
>>>> operation comes from the owner of the file.  NFSv3 clients are then
>>>> careful to perform necessary access checks on open to ensure that this
>>>> owner-override rule doesn't grant too many permissions.
>>>>
>>>> That allows NFSv3 applications to see behavior that's mostly like a
>>>> local filesystem, without opening much of a security hole (since the
>>>> owner could always chmod anyway).
>>>>
>>>> So, knfsd is making this special exception--but gluster (which I believe
>>>> it's exporting in this case, via fuse?)--probably doesn't....  I'm not
>>>> sure what you can do about that.
>>>>
>>>> --b.
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
