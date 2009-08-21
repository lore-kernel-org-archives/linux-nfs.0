From: Peter Staubach <staubach@redhat.com>
Subject: Re: mount.nfs: access denied by server
Date: Fri, 21 Aug 2009 16:41:47 -0400
Message-ID: <4A8F068B.8060207@redhat.com>
References: <1250822171.6514.29.camel@heimdal.trondhjem.org> <BAE89B4F-CA8C-46B2-82EA-9BAA438C1DF7@oracle.com> <20090821182418.GE21043@fieldses.org> <760BE185-BE57-42C2-817C-6776B5B66667@sun.com> <0BCE5960-E78A-4433-8D38-8DC2E6A0FDCF@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Cc: Thomas Haynes <Thomas.Haynes-UdXhSnd/wVw@public.gmane.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <Chuck.Lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5955 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932441AbZHUUl5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 21 Aug 2009 16:41:57 -0400
In-Reply-To: <0BCE5960-E78A-4433-8D38-8DC2E6A0FDCF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> On Aug 21, 2009, at 3:07 PM, Thomas Haynes wrote:
>> Sent from my iPhone
>>
>> On Aug 21, 2009, at 1:24 PM, "J. Bruce Fields" <bfields@fieldses.org=
>
>> wrote:
>>
>>> On Fri, Aug 21, 2009 at 02:16:08PM -0400, Chuck Lever wrote:
>>>> I want to understand the server bug a little more.  I glanced over=
 RFC
>>>> 2623 and didn't see anything specific.
>>>>
>>>> Is it the case that only Linux NFSD does this, or do other servers=
 do
>>>> it?  In other words, is this a typical server response, and if so,=
 is
>>>> there a specific semantic attached to it?
>>>>
>>>> If no list is provided, should the client assume that only AUTH_NO=
NE
>>>> and
>>>> AUTH_SYS are supported, or instead, perhaps that the client can tr=
y to
>>>> use any flavor?  In other words, if no list is provided, let the m=
ount
>>>> proceed no matter what was specified by sec=3D ?
>>>
>>> I think the safest behavior on the client would be something like:
>>>
>>>   - If an explicit sec=3D is provided on the client, try that
>>>     flavor.  Otherwise:
>>>       - If the server returned a nonempty list, pick something
>>>         off that list.  Otherwise:
>>>             - Try auth_sys.
>>>
>>
>> Which is pretty much what we do. The exception being that the defaul=
t
>> flavor is a setting - and probably always AUTH_SYS...
>=20
> I'm still not sure what is the right thing to do here.  Looking at 18=
13,
> it says:
>=20
>    DESCRIPTION
>       Procedure MNT maps a pathname on the server to a file
>       handle.  The pathname is an ASCII string that describes a
>       directory on the server. If the call is successful
>       (MNT3_OK), the server returns an NFS version 3 protocol
> ->    file handle and a vector of RPC authentication flavors
> ->    that are supported with the client=92s use of the file
> ->    handle (or any file handles derived from it).  The
>       authentication flavors are defined in Section 7.2 and
>       section 9 of [RFC1057].
>=20
>    IMPLEMENTATION
>       If mountres3.fhs_status is MNT3_OK, then
>       mountres3.mountinfo contains the file handle for the
> ->    directory and a list of acceptable authentication
> ->    flavors.  This file handle may only be used in the NFS
>       version 3 protocol.  This procedure also results in the
>       server adding a new entry to its mount list recording that
>       this client has mounted the directory. AUTH_UNIX
>       authentication or better is required.
>=20
> This suggests pretty clearly that the client should treat the returne=
d
> auth flavor list as the list of flavors supported for this mount poin=
t,
> not as a preference list to be used only if the client is trying to
> guess what flavor to use.  Is my reading incorrect?  Help!  :-)
>=20

Your interpretation is the correct one, Chuck.  The list
returned from the server is supposed to be the definitive
list of authentication flavors that the server will accept
from the client.

A server which returns no flavors is by definition, broken.

		ps

>=20
>>
>>
>>
>>> --b.
>>>
>>>>
>>>> Thanks for any clarification.
>>>>
>>>> Begin forwarded message:
>>>>
>>>>> From: Trond Myklebust <trond.myklebust@fys.uio.no>
>>>>> Date: August 20, 2009 10:36:11 PM GMT-04:00
>>>>> To: Wu Fengguang <fengguang.wu@intel.com>, "Mr. Charles Edward Le=
ver"
>>>>> <Chuck.Lever@oracle.com>
>>>>> Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, LKML
>>>>> <linux-kernel@vger.kernel.org>
>>>>> Subject: Re: mount.nfs: access denied by server
>>>>>
>>>>> On Fri, 2009-08-21 at 09:27 +0800, Wu Fengguang wrote:
>>>>>> On Thu, Aug 20, 2009 at 09:02:29PM +0800, Trond Myklebust wrote:
>>>>>>> On Thu, 2009-08-20 at 15:13 +0800, Wu Fengguang wrote:
>>>>>>>> Hi,
>>>>>>>>
>>>>>>>> After upgrading NFS client kernel to latest linux-next, NFS mo=
unt
>>>>>>>> failed:
>>>>>>>>
>>>>>>>>      # mount -t nfs pxe:/cc /cc
>>>>>>>>      mount.nfs: access denied by server while mounting pxe:/cc
>>>>>>>>
>>>>>>>>      # uname -a
>>>>>>>>      Linux hp 2.6.31-rc6-next-20090818 #61 SMP Thu Aug 20
>>>>>>>> 14:46:10 CST 2009 x86_64 GNU/Linux
>>>>>>>>
>>>>>>>> However server log says OK:
>>>>>>>>
>>>>>>>>      Aug 20 15:02:09 wu-t61 mountd[4599]: authenticated mount
>>>>>>>> request from 192.168.11.6:973 for /cc (/cc)
>>>>>>>>      Aug 20 15:02:09 wu-t61 mountd[4599]: authenticated unmoun=
t
>>>>>>>> request from 192.168.11.6:974 for /cc (/cc)
>>>>>>>>
>>>>>>>> However-2: nfsroot can be mounted at boot time. Server kernel =
has
>>>>>>>> always been 2.6.30.
>>>>>>>>
>>>>>>>> Any ideas?
>>>>>>>>
>>>>>>>> Thanks,
>>>>>>>> Fengguang
>>>>>>>
>>>>>>> Can you try again after enabling mount debugging on the NFS cli=
ent?
>>>>>>>
>>>>>>> echo 512 > /proc/sys/sunrpc/nfs_debug
>>>>>>
>>>>>> I used 1024 and found the mount failed here in nfs_walk_authlist=
():
>>>>>>
>>>>>>      dfprintk(MOUNT, "NFS: server does not support requested aut=
h
>>>>>> flavor\ n");
>>>>>>      nfs_umount(request);
>>>>>
>>>>> Thanks Fengguang!
>>>>>
>>>>> Chuck, this looks like one of yours. Could it be that you are hit=
ting
>>>>> the same Linux knfsd bug that Tom Haynes saw with a Solaris clien=
t?
>>>>> AFAICR, the problem was that existing nfs servers do not set a de=
fault
>>>>> auth flavour, and so you just have to try with auth_sys and see i=
f it
>>>>> succeeds...
>>>>>
>>>>> Cheers
>>>>> Trond
>>>>>
>>>>
>>>> --=20
>>>> Chuck Lever
>>>> chuck[dot]lever[at]oracle[dot]com
>>>>
>>>>
>>>>
>=20
> --=20
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>=20
>=20
>=20
> --=20
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

