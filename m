From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: unmount -l does not send unmount request to the server
Date: Fri, 19 Mar 2010 16:22:32 -0400
Message-ID: <4BA3DD08.20209@oracle.com>
References: <4B530EFF.9000205@inria.fr> <7123090D-5BB9-4CF5-A024-56345DD8136F@oracle.com> <4B9D49CC.8080603@inria.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Cc: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Guillaume Rousse <Guillaume.Rousse-MZpvjPyXg2s@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:18569 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751092Ab0CSUYg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Mar 2010 16:24:36 -0400
In-Reply-To: <4B9D49CC.8080603-MZpvjPyXg2s@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/14/2010 04:40 PM, Guillaume Rousse wrote:
> Le 19/01/2010 17:37, Chuck Lever a =E9crit :
>> As far as I understand it, "-l" means the kernel will do the local
>> detach from the system's file name space whenever there are no more
>> users (ie entirely asynchronously).  I don't think umount2(MNT_DETAC=
H)
>> indicates whether the kernel was able to completely unmount that fil=
e
>> system by the time the call returns, so there's perhaps no way for
>> umount.nfs to know whether it should send the UMNT request.  If the
>> server is slow or unresponsive, that file system won't be unmounted
>> until long after the umount.nfs command has exited.
>>
>> This shouldn't be much of a big deal, since the server's rmtab is
>> "ornamental" according to the man page.  No one should rely on it be=
ing
>> accurate.
>>
>> A possible way to fix this is to have the kernel send the UMNT.
> It makes sense, but it doesn't seem to trigger much interest :)
>
> Should I open a bug somewhere, to ensure the issue won't be forgotten=
 ?

You might consider filing a bug in the NFSv4 bugzilla on linux-nfs.org.

--=20
chuck[dot]lever[at]oracle[dot]com
