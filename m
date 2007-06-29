From: "Erik A. Espinoza" <espinoza@ligo.caltech.edu>
Subject: [Fwd: Re:  NFSv4 uninitialized mtime]
Date: Fri, 29 Jun 2007 15:28:19 -0700
Message-ID: <46858783.50709@ligo.caltech.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------090704070500090302010202"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I4Ox2-0001mX-Oq
	for nfs@lists.sourceforge.net; Fri, 29 Jun 2007 15:28:28 -0700
Received: from acrux.ligo.caltech.edu ([131.215.115.14])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I4Ox4-0007LD-QO
	for nfs@lists.sourceforge.net; Fri, 29 Jun 2007 15:28:32 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------090704070500090302010202
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Greetings,

Here are the results
-bash-3.00$ stat badmtime.out
  File: `badmtime.out'
  Size: 0               Blocks: 1          IO Block: 1048576 regular
empty file
Device: 1ch/28d Inode: 107116      Links: 1
Access: (0644/-rw-r--r--)  Uid: ( 5026/anderson)   Gid: ( 5026/anderson)
Access: 2007-06-29 14:42:51.026996877 -0700
Modify: 1977-06-21 02:23:11.159764000 -0700
Change: 2007-06-29 14:42:51.039780780 -0700


This was on GIT kernel from git://git.linux-nfs.org/pub/linux/nfs-2.6
based on 2.6.22-rc6. Attached is the tcpdump of the traffic.

Thanks,
Erik



Jeff Layton wrote:
> On Wed, 27 Jun 2007 19:53:27 -0700
> Stuart Anderson <anderson@ligo.caltech.edu> wrote:
> 
>> On Wed, Jun 27, 2007 at 09:15:59PM -0400, Jeff Layton wrote:
>>> On Wed, 27 Jun 2007 17:59:57 -0700
>>> Stuart Anderson <anderson@ligo.caltech.edu> wrote:
>>>
>>>> More precisely, applying this patch to the 2.6.20.14 kernel plus the
>>>> revalidate-the-fsid patch did not result in any changes. Does the
>>>> O_EXCL patch require some other supporting patches relative to 2.6.20.14?
>>>>
>>>> or perhaps it is necessary to rebase to a newer kernel before applying it?
>>>> even tough it applies, builds and runs with 2.6.20.14?
>>>>
>>>> Thanks.
>>>>
>>> With Linux, both client and server side were broken in this respect.
>>> The server didn't set the bitmask in the reply and the client didn't
>>> look at it anyway. It's possible that Solaris server is broken in this
>>> regard as well. It would be interesting to see a capture here,
>>> particularly one containing the reply from the CREATE.
>> Possible, but when we switch the client from Linux to Solaris and share
>> the same filesytem from the same server there are no O_EXCL problems.
>>
> 
> NFSv3 didn't use this bitmask, so clients tended to just clobber the
> mtime and atime on the subsequent setattr. It's possible that Solaris
> is using the old semantics here with NFSv4. Of course, all of this is
> speculation :-), a capture should give us a better clue.
> 
>> I will see if we can capture the bits. Any recomendations on which tool
>> with what options would be most useful to capture the useful traffic?
>>
> 
> tcpdump is what I'd recommend. It's pretty standard issue on Linux
> boxes these days. From the client:
> 
> # tcpdump -i eth0 -s 0 -w /tmp/nfs4_create.pcap host nfs_server and port 2049
> 
> You might need to modify it some depending on your setup. that should
> capture all NFS packets into /tmp/nfs4_create.pcap. Start up tcpdump,
> run the reproducer, and then kill the tcpdump. That should give us a
> pretty small capture file that just has what we need in it. If you want
> to look at it yourself, then you can use wireshark (aka ethereal) on
> Linux.
> 
> I have a solaris 11 qemu image. I'll try to reproduce this using it as
> a server today sometime.
> 
>>> Exactly what version of Solaris is the server running?
>> # cat /etc/release 
>>                         Solaris 10 11/06 s10x_u3wos_10 X86
>>            Copyright 2006 Sun Microsystems, Inc.  All Rights Reserved.
>>                         Use is subject to license terms.
>>                            Assembled 14 November 2006
>> # uname -v
>> Generic_118855-36
>>
>>
>> Somewhat related is the reason that we are tring NFSV4 on Linux clients is
>> that with NFSV3 ACL's do not work between Linux and Solaris if the filesystem
>> on the Solaris server is ZFS, e.g., cp -p will generate interesting error
>> messages. While I would rather stay with NFSV4 if possible, has anyone
>> gotten this configuration to work with V3?
>>
>>>> On Wed, Jun 27, 2007 at 05:49:04PM -0700, Stuart Anderson wrote:
>>>>> Unfortunately this patch did not have any observable affects.
>>>>>
>>>>> On Wed, Jun 27, 2007 at 07:43:25PM -0400, Trond Myklebust wrote:
>>>>>> On Wed, 2007-06-27 at 16:31 -0700, Stuart Anderson wrote:
>>>>>>> The following simple program creates files with un-initialized mtime values
>>>>>>> on a Linux NFSv4 client mounting from a Solaris NFSv4 server--at least the
>>>>>>> mtimes are wildly different each time the program is run. The problem is
>>>>>>> reproducible but does not happen under any of the following circumstances:
>>>>>>>
>>>>>>> 1) Drop O_EXCL from open() call.
>>>>>>> 2) NFS mount using v3.
>>>>>>> 3) Switch NFS v4 client from Linux to Solaris.
>>>>>>>
>>>>>>> This is on an FC4 machine with the 2.6.20.14 kernel plus Trond's recent
>>>>>>> revalidate-the-fsid-on-the-current-dir-not-the-root-dir patch
>>>>>>> and nfs-utils 1.0.9-16 backported from CentOS 5.
>>>>>>>
>>>>>>> Thanks.
>>>>>> Doesn't Jeff's patch fix it?
>>>>>>
>>>>>> Trond
>>>>>>
>>>>>>
>>>>>> From: Jeff Layton <jlayton@redhat.com>
>>>>>> Date: Tue, 5 Jun 2007 14:49:03 -0400
>>>>>> NFS4: on a O_EXCL OPEN make sure SETATTR sets the fields holding the
>>>>>> 	verifier
>>>>>> Subject: No Subject
>>>>>>
>>>>>> The Linux NFS4 client simply skips over the bitmask in an O_EXCL open
>>>>>> call and so it doesn't bother to reset any fields that may be holding
>>>>>> the verifier. This patch has us save the first two words of the bitmask
>>>>>> (which is all the current client has #defines for). The client then
>>>>>> later checks this bitmask and turns on the appropriate flags in the
>>>>>> sattr->ia_verify field for the following SETATTR call.
>>>>>>
>>>>>> This patch only currently checks to see if the server used the atime
>>>>>> and mtime slots for the verifier (which is what the Linux server uses
>>>>>> for this). I'm not sure of what other fields the server could
>>>>>> reasonably use, but adding checks for others should be trivial.
>>>>>>
>>>>>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>>>>>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>>>>> ---
>>>>>>
>>>>>>  fs/nfs/nfs4proc.c       |   20 ++++++++++++++++++++
>>>>>>  fs/nfs/nfs4xdr.c        |    9 +++++++--
>>>>>>  include/linux/nfs4.h    |    1 +
>>>>>>  include/linux/nfs_xdr.h |    1 +
>>>>>>  4 files changed, 29 insertions(+), 2 deletions(-)
>>>>>>
>>>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>>>>> index 3cc7544..fee2d14 100644
>>>>>> --- a/fs/nfs/nfs4proc.c
>>>>>> +++ b/fs/nfs/nfs4proc.c
>>>>>> @@ -943,6 +943,22 @@ static struct nfs4_state *nfs4_open_delegated(struct inode *inode, int flags, st
>>>>>>  }
>>>>>>  
>>>>>>  /*
>>>>>> + * on an EXCLUSIVE create, the server should send back a bitmask with FATTR4-*
>>>>>> + * fields corresponding to attributes that were used to store the verifier.
>>>>>> + * Make sure we clobber those fields in the later setattr call
>>>>>> + */
>>>>>> +static inline void nfs4_exclusive_attrset(struct nfs4_opendata *opendata, struct iattr *sattr)
>>>>>> +{
>>>>>> +	if ((opendata->o_res.attrset[1] & FATTR4_WORD1_TIME_ACCESS) &&
>>>>>> +	    !(sattr->ia_valid & ATTR_ATIME_SET))
>>>>>> +		sattr->ia_valid |= ATTR_ATIME;
>>>>>> +
>>>>>> +	if ((opendata->o_res.attrset[1] & FATTR4_WORD1_TIME_MODIFY) &&
>>>>>> +	    !(sattr->ia_valid & ATTR_MTIME_SET))
>>>>>> +		sattr->ia_valid |= ATTR_MTIME;
>>>>>> +}
>>>>>> +
>>>>>> +/*
>>>>>>   * Returns a referenced nfs4_state
>>>>>>   */
>>>>>>  static int _nfs4_do_open(struct inode *dir, struct path *path, int flags, struct iattr *sattr, struct rpc_cred *cred, struct nfs4_state **res)
>>>>>> @@ -973,6 +989,9 @@ static int _nfs4_do_open(struct inode *dir, struct path *path, int flags, struct
>>>>>>  	if (status != 0)
>>>>>>  		goto err_opendata_free;
>>>>>>  
>>>>>> +	if (opendata->o_arg.open_flags & O_EXCL)
>>>>>> +		nfs4_exclusive_attrset(opendata, sattr);
>>>>>> +
>>>>>>  	status = -ENOMEM;
>>>>>>  	state = nfs4_opendata_to_nfs4_state(opendata);
>>>>>>  	if (state == NULL)
>>>>>> @@ -1784,6 +1803,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
>>>>>>  		status = nfs4_do_setattr(state->inode, &fattr, sattr, state);
>>>>>>  		if (status == 0)
>>>>>>  			nfs_setattr_update_inode(state->inode, sattr);
>>>>>> +		nfs_post_op_update_inode(state->inode, &fattr);
>>>>>>  	}
>>>>>>  	if (status == 0 && (nd->flags & LOOKUP_OPEN) != 0)
>>>>>>  		status = nfs4_intent_set_file(nd, &path, state);
>>>>>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>>>>>> index 8003c91..5efd314 100644
>>>>>> --- a/fs/nfs/nfs4xdr.c
>>>>>> +++ b/fs/nfs/nfs4xdr.c
>>>>>> @@ -3269,7 +3269,7 @@ static int decode_delegation(struct xdr_stream *xdr, struct nfs_openres *res)
>>>>>>  static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
>>>>>>  {
>>>>>>          __be32 *p;
>>>>>> -        uint32_t bmlen;
>>>>>> +        uint32_t savewords, bmlen, i;
>>>>>>          int status;
>>>>>>  
>>>>>>          status = decode_op_hdr(xdr, OP_OPEN);
>>>>>> @@ -3287,7 +3287,12 @@ static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
>>>>>>                  goto xdr_error;
>>>>>>  
>>>>>>          READ_BUF(bmlen << 2);
>>>>>> -        p += bmlen;
>>>>>> +	savewords = min_t(uint32_t, bmlen, NFS4_BITMAP_SIZE);
>>>>>> +	for (i = 0; i < savewords; ++i)
>>>>>> +		READ32(res->attrset[i]);
>>>>>> +
>>>>>> +	p += (bmlen - savewords);
>>>>>> +
>>>>>>  	return decode_delegation(xdr, res);
>>>>>>  xdr_error:
>>>>>>  	dprintk("%s: Bitmap too large! Length = %u\n", __FUNCTION__, bmlen);
>>>>>> diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
>>>>>> index 7e7f33a..8726491 100644
>>>>>> --- a/include/linux/nfs4.h
>>>>>> +++ b/include/linux/nfs4.h
>>>>>> @@ -15,6 +15,7 @@
>>>>>>  
>>>>>>  #include <linux/types.h>
>>>>>>  
>>>>>> +#define NFS4_BITMAP_SIZE	2
>>>>>>  #define NFS4_VERIFIER_SIZE	8
>>>>>>  #define NFS4_STATEID_SIZE	16
>>>>>>  #define NFS4_FHSIZE		128
>>>>>> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
>>>>>> index 10c26ed..f7100df 100644
>>>>>> --- a/include/linux/nfs_xdr.h
>>>>>> +++ b/include/linux/nfs_xdr.h
>>>>>> @@ -144,6 +144,7 @@ struct nfs_openres {
>>>>>>  	nfs4_stateid		delegation;
>>>>>>  	__u32			do_recall;
>>>>>>  	__u64			maxsize;
>>>>>> +	__u32			attrset[NFS4_BITMAP_SIZE];
>>>>>>  };
>>>>>>  
>>>>>>  /*
>>>>>
>>>>> -- 
>>>>> Stuart Anderson  anderson@ligo.caltech.edu
>>>>> http://www.ligo.caltech.edu/~anderson
>>>> -- 
>>>> Stuart Anderson  anderson@ligo.caltech.edu
>>>> http://www.ligo.caltech.edu/~anderson
>>>
>>> -- 
>>> Jeff Layton <jlayton@redhat.com>
>> -- 
>> Stuart Anderson  anderson@ligo.caltech.edu
>> http://www.ligo.caltech.edu/~anderson
> 
> 


-- 
Erik A. Espinoza
Systems Administrator
LIGO/Caltech - MS 18-34
Pasadena, CA 91125
Ph: 626-395-8517

--------------090704070500090302010202
Content-Type: application/octet-stream;
 name="nfs4_create.pcap"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="nfs4_create.pcap"

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
lpw6VdUPgBAB9YLHAAABAQgKAAPxMQOj6aM=
--------------090704070500090302010202
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------090704070500090302010202
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------090704070500090302010202--
