From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Bug#492970: (was: nfs-utils-1.1.3 released)
Date: Fri, 8 Aug 2008 21:06:46 -0400
Message-ID: <2237EBE9-FE80-4B9A-B908-1533C47BBD0F@oracle.com>
References: <488D718F.200@RedHat.com>
	<20080801131533.GN14057@debianrules.debiancolombia.org>
	<20080802172529.GC30454@fieldses.org>
	<87myjul1fk.fsf@burly.wgtn.ondioline.org>
	<20080803151022.GA31484@fieldses.org>
	<60C652E1-512E-484A-874E-01997B688505@oracle.com>
	<87d4ko5wlx.fsf@burly.wgtn.ondioline.org>
	<9692E351-7140-4AD8-99F8-C9271F54CD5F@oracle.com>
	<863alj9s8p.fsf@gere.msconsult.dk>
	<5535F9D8-CD96-4807-80B3-7FD4B3983794@oracle.com>
	<20080807150514.GA3696@xanadu.blop.info>
	<6A0B8017-9FCB-4CF1-88F0-8E5752AC22EC@oracle.com>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset="iso-8859-1"
Cc: bcwong@cisco.com
To: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <6A0B8017-9FCB-4CF1-88F0-8E5752AC22EC@oracle.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 7, 2008, at 12:29 PM, Chuck Lever wrote:
> On Aug 7, 2008, at 11:05 AM, Lucas Nussbaum wrote:
>> On 06/08/08 at 12:21 -0400, Chuck Lever wrote:
>>> On Aug 5, 2008, at 3:28 PM, Rasmus B=F8g Hansen wrote:
>>>> Chuck Lever <chuck.lever@oracle.com> writes:
>>>>> On Aug 4, 2008, at 4:55 PM, Paul Collins wrote:
>>>>>> Chuck Lever <chuck.lever@oracle.com> writes:
>>>>>>> On Aug 3, 2008, at 11:10 AM, J. Bruce Fields wrote:
>>>>>>>> On Mon, Aug 04, 2008 at 12:37:19AM +1200, Paul Collins wrote:
>>>>>>>>> "J. Bruce Fields" <bfields@fieldses.org> writes:
>>>>>>>>>
>>>>>>>>>> On Fri, Aug 01, 2008 at 11:15:33PM +1000, An=EDbal Monsalve
>>>>>>>>>> Salazar
>>>>>>>>>> wrote:
>>>>>>>>>>> On Mon, Jul 28, 2008 at 03:13:19AM -0400, Steve Dickson  =

>>>>>>>>>>> wrote:
>>>>>>>>>>>> I just cut the 1.1.3 nfs-utils release. Unfortunately
>>>>>>>>>>>> I'm having
>>>>>>>>>>>> issues accessing my kernel.org account so for the moment  =

>>>>>>>>>>>> the
>>>>>>>>>>>> tar ball is only available on SourceForge:
>>>>>>>>>>>>
>>>>>>>>>>>> http://sourceforge.net/projects/nfs
>>>>>>>>>>>> [...]
>>>>>>>>>>>
>>>>>>>>>>> 1.1.3 clients don't work with a 1.0.10 server anymore.
>>>>>>>>>>
>>>>>>>>>> Very weird--it might make sense if upgrading nfs-utils  =

>>>>>>>>>> broke the
>>>>>>>>>> mount
>>>>>>>>>> itself, but here it seems the mount is succeeding and  =

>>>>>>>>>> subsequent
>>>>>>>>>> file
>>>>>>>>>> access (which I'd expect to only involve the in-kernel client
>>>>>>>>>> code) is
>>>>>>>>>> failing.  Maybe there's some difference in the mount options?
>>>>>>>>>> What does
>>>>>>>>>> /proc/self/mounts say?  I assume these are all v2 or v3  =

>>>>>>>>>> mounts?
>>>>>>>>>
>>>>>>>>> I discovered today that I was no longer able to write to the  =

>>>>>>>>> v3
>>>>>>>>> mount on
>>>>>>>>> my 1.1.2 server.  I checked /proc/mounts and noticed  =

>>>>>>>>> sec=3Dnull on
>>>>>>>>> the
>>>>>>>>> mount.  Either adding sec=3Dsys to the client's mount options or
>>>>>>>>> downgrading to nfs-common 1.1.2 on the client fixes the  =

>>>>>>>>> problem.
>>>>>>>>
>>>>>>>> That would do it!
>>>>>>>>
>>>>>>>> So it sounds like there's a bug that causes mount.nfs to get  =

>>>>>>>> the
>>>>>>>> default
>>>>>>>> mount options wrong?
>>>>>>>
>>>>>>> I'm not sure I'm following this.  I can't think of a user-space
>>>>>>> mount.nfs change in 1.1.3 that would affect the sec=3D option.
>>>>>>>
>>>>>>> Paul, which kernel are you running on your clients?
>>>>>>
>>>>>> Either 2.6.26 or 2.6.27-rc1+.  I'll double-check.
>>>>>
>>>>> It would be interesting if you could try both.  I suspect 2.6.26
>>>>> doesn't exhibit this problem, as 27-rc1 has changes in the NFS  =

>>>>> mount
>>>>> parser that affect "sec=3D".
>>>>
>>>> I had the problem with 2.6.26. I didn't try 2.6.27-rc1 on that
>>>> machine.
>>>>
>>>>> Also, enabling NFS mount debugging messages when performing the  =

>>>>> mount
>>>>> that eventually doesn't work would be enlightening (for me).   =

>>>>> Either:
>>>>
>>>> I won't be around that machine for a week or so.
>>>>
>>>>>> Whichever one it was, the problem was present with 1.1.3  =

>>>>>> installed,
>>>>>> and
>>>>>> not present with 1.1.2 installed.
>>>>
>>>> Same here.
>>>
>>> Thanks for the report.
>>>
>>> In addition to the debugging mentioned above, anyone encountering  =

>>> this
>>> regression can also try a git bisect on nfs-utils (between 1.1.2 and
>>> 1.1.3).
>>
>> Hi,
>>
>> Some more info on this:
>>
>> The problem only arises when the debian specific patch
>> debian/patches/05-default-use-old-mount-interface.patch is applied.
>> (it works fine with stock 1.1.3)
>
> OK, that makes it more clear that the presenting problem is in the  =

> legacy mount.nfs path, and explains why perhaps the reporters were  =

> finding this problem on late model kernels that should be using the  =

> text-based interface.
>
> The text-based interface is probably not correct either, but is  =

> using a default setting that avoids this problem, rather than  =

> negotiating based on the server's list.
>
> I'll have to get off my butt and look at the kernel's mountd client  =

> to verify this.


Confirmed.  The kernel's mountd client doesn't even bother to  =

unmarshal the auth flavor list in the server's reply.

I'll work on a fix.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
