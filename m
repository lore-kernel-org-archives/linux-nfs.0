From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: (was: nfs-utils-1.1.3 released)
Date: Mon, 4 Aug 2008 11:32:45 -0400
Message-ID: <60C652E1-512E-484A-874E-01997B688505@oracle.com>
References: <488D718F.200@RedHat.com>
	<20080801131533.GN14057@debianrules.debiancolombia.org>
	<20080802172529.GC30454@fieldses.org>
	<87myjul1fk.fsf@burly.wgtn.ondioline.org>
	<20080803151022.GA31484@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset="iso-8859-1"
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	=?ISO-8859-1?Q?Rasmus_B=F8g_Hansen?= <rasmus@msconsult.dk>,
	492970@bugs.debian.org, Christian Surchi <csurchi@debian.org>,
	Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20080803151022.GA31484@fieldses.org>
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

On Aug 3, 2008, at 11:10 AM, J. Bruce Fields wrote:
> On Mon, Aug 04, 2008 at 12:37:19AM +1200, Paul Collins wrote:
>> "J. Bruce Fields" <bfields@fieldses.org> writes:
>>
>>> On Fri, Aug 01, 2008 at 11:15:33PM +1000, An=EDbal Monsalve Salazar  =

>>> wrote:
>>>> On Mon, Jul 28, 2008 at 03:13:19AM -0400, Steve Dickson wrote:
>>>>> I just cut the 1.1.3 nfs-utils release. Unfortunately I'm having
>>>>> issues accessing my kernel.org account so for the moment the
>>>>> tar ball is only available on SourceForge:
>>>>>
>>>>>    http://sourceforge.net/projects/nfs
>>>>> [...]
>>>>
>>>> 1.1.3 clients don't work with a 1.0.10 server anymore.
>>>
>>> Very weird--it might make sense if upgrading nfs-utils broke the  =

>>> mount
>>> itself, but here it seems the mount is succeeding and subsequent  =

>>> file
>>> access (which I'd expect to only involve the in-kernel client  =

>>> code) is
>>> failing.  Maybe there's some difference in the mount options?   =

>>> What does
>>> /proc/self/mounts say?  I assume these are all v2 or v3 mounts?
>>
>> I discovered today that I was no longer able to write to the v3  =

>> mount on
>> my 1.1.2 server.  I checked /proc/mounts and noticed sec=3Dnull on the
>> mount.  Either adding sec=3Dsys to the client's mount options or
>> downgrading to nfs-common 1.1.2 on the client fixes the problem.
>
> That would do it!
>
> So it sounds like there's a bug that causes mount.nfs to get the  =

> default
> mount options wrong?

I'm not sure I'm following this.  I can't think of a user-space  =

mount.nfs change in 1.1.3 that would affect the sec=3D option.

Paul, which kernel are you running on your clients?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
