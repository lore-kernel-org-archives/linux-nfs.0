From: rasmus@msconsult.dk (Rasmus =?UTF-8?Q?B=C3=B8g?= Hansen)
Subject: Bug#492970: (was: nfs-utils-1.1.3 released)
Date: Tue, 05 Aug 2008 21:28:06 +0200
Message-ID: <863alj9s8p.fsf@gere.msconsult.dk>
References: <488D718F.200@RedHat.com>
	<20080801131533.GN14057@debianrules.debiancolombia.org>
	<20080802172529.GC30454@fieldses.org>
	<87myjul1fk.fsf@burly.wgtn.ondioline.org>
	<20080803151022.GA31484@fieldses.org>
	<60C652E1-512E-484A-874E-01997B688505@oracle.com>
	<87d4ko5wlx.fsf@burly.wgtn.ondioline.org>
	<9692E351-7140-4AD8-99F8-C9271F54CD5F@oracle.com>
Reply-To: rasmus@msconsult.dk (Rasmus =?UTF-8?Q?B=C3=B8g?= Hansen), 492970@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Paul Collins <paul@burly.ondioline.org>,  "J. Bruce Fields"
 <bfields@fieldses.org>,  Linux NFS Mailing List
 <linux-nfs@vger.kernel.org>,  Rasmus =?UTF-8?Q?B=C3=B8g?= Hansen
 <rasmus@msconsult.dk>,  492970@bugs.debian.org,  Christian Surchi
 <csurchi@debian.org>,  Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Sender: Rasmus =?UTF-8?Q?B=C3=B8g?= Hansen <rasmus@msconsult.dk>
Resent-Message-ID: <handler.492970.B492970.121796453124867@bugs.debian.org>
In-Reply-To: <9692E351-7140-4AD8-99F8-C9271F54CD5F@oracle.com> (Chuck Lever's
	message of "Tue, 5 Aug 2008 11:20:12 -0400")
Sender: Rasmus =?UTF-8?Q?B=C3=B8g?= Hansen <rasmus@msconsult.dk>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever <chuck.lever@oracle.com> writes:

> On Aug 4, 2008, at 4:55 PM, Paul Collins wrote:
>> Chuck Lever <chuck.lever@oracle.com> writes:
>>> On Aug 3, 2008, at 11:10 AM, J. Bruce Fields wrote:
>>>> On Mon, Aug 04, 2008 at 12:37:19AM +1200, Paul Collins wrote:
>>>>> "J. Bruce Fields" <bfields@fieldses.org> writes:
>>>>>
>>>>>> On Fri, Aug 01, 2008 at 11:15:33PM +1000, An=C3=ADbal Monsalve Salaz=
ar
>>>>>> wrote:
>>>>>>> On Mon, Jul 28, 2008 at 03:13:19AM -0400, Steve Dickson wrote:
>>>>>>>> I just cut the 1.1.3 nfs-utils release. Unfortunately I'm having
>>>>>>>> issues accessing my kernel.org account so for the moment the
>>>>>>>> tar ball is only available on SourceForge:
>>>>>>>>
>>>>>>>>   http://sourceforge.net/projects/nfs
>>>>>>>> [...]
>>>>>>>
>>>>>>> 1.1.3 clients don't work with a 1.0.10 server anymore.
>>>>>>
>>>>>> Very weird--it might make sense if upgrading nfs-utils broke the
>>>>>> mount
>>>>>> itself, but here it seems the mount is succeeding and subsequent
>>>>>> file
>>>>>> access (which I'd expect to only involve the in-kernel client
>>>>>> code) is
>>>>>> failing.  Maybe there's some difference in the mount options?
>>>>>> What does
>>>>>> /proc/self/mounts say?  I assume these are all v2 or v3 mounts?
>>>>>
>>>>> I discovered today that I was no longer able to write to the v3
>>>>> mount on
>>>>> my 1.1.2 server.  I checked /proc/mounts and noticed sec=3Dnull on
>>>>> the
>>>>> mount.  Either adding sec=3Dsys to the client's mount options or
>>>>> downgrading to nfs-common 1.1.2 on the client fixes the problem.
>>>>
>>>> That would do it!
>>>>
>>>> So it sounds like there's a bug that causes mount.nfs to get the
>>>> default
>>>> mount options wrong?
>>>
>>> I'm not sure I'm following this.  I can't think of a user-space
>>> mount.nfs change in 1.1.3 that would affect the sec=3D option.
>>>
>>> Paul, which kernel are you running on your clients?
>>
>> Either 2.6.26 or 2.6.27-rc1+.  I'll double-check.
>
> It would be interesting if you could try both.  I suspect 2.6.26
> doesn't exhibit this problem, as 27-rc1 has changes in the NFS mount
> parser that affect "sec=3D".

I had the problem with 2.6.26. I didn't try 2.6.27-rc1 on that
machine.

> Also, enabling NFS mount debugging messages when performing the mount
> that eventually doesn't work would be enlightening (for me).  Either:

I won't be around that machine for a week or so.

>> Whichever one it was, the problem was present with 1.1.3 installed,
>> and
>> not present with 1.1.2 installed.

Same here.

Regards
/Rasmus

--=20
Rasmus B=C3=B8g Hansen
MSC Aps
B=C3=B8gesvinget 8
2740 Skovlunde
44 53 93 66
