From: Eli Stair <estair@ilm.com>
Subject: Re: Linux client cache corruption,
 system call returning    incorrectly
Date: Tue, 27 Mar 2007 12:21:09 -0700
Message-ID: <46096EA5.6020408@ilm.com>
References: <45E796B7.9010707@ilm.com>
	<EXNANE01XvpFVjCRGry00000034@exnane01.hq.netapp.com>
	<45E89DF9.9000303@ilm.com>
	<EXNANE01WtIIZS2TRqf0000003f@exnane01.hq.netapp.com>
	<EXNANE01pH71yEXUIEA00000045@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWHEI-0008NB-LQ
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 12:21:15 -0700
Received: from gateway01.lucasfilm.com ([63.82.98.221])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWHEK-0003yZ-7Q
	for nfs@lists.sourceforge.net; Tue, 27 Mar 2007 12:21:17 -0700
In-Reply-To: <EXNANE01pH71yEXUIEA00000045@exnane01.hq.netapp.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


I'm reporting back on this issue, and have found that this behaviour 
(bug) was introduced in kernel 2.6.17.  All prior versions tested, 
2.6.15 through 2.6.16.44, work fine.  Starting in 2.6.17 this ENOENT 
(sorry for the type-o stating ENOFILE) error starts occuring, and is 
present then up to and including 2.6.21-rc4.

To follow up on some previous questions:

1) Kernels in use.
I'm using kernel.org sources.  The patch from Neil Brown I mentioned I 
applied to 2.6.20 only, and it did not impact the bug we're discussing 
here.  Trond's NFS_ALL, and CITI's current patchset for 2.6.20 don't 
rectify this either.



2) Client & Server details.
Mounts are set up as follows (endor is SpinFS 2.5.5.p9, hoth is GX OnTap
10.0.1p2).  This same bug is occuring when accessing over either of
these platforms, and additionally linux kernel 2.6.18.2..  It seems the
syntax was altered beetween these two versions for version and protocol,
and 'lock' was removed by default from 2.6.17 (these mounts occur using
the same autofs), as specified below however, these options have been
tried on several testcases and they still occur.  Not sure yet why
locking ceases to apply to the mounts starting at 2.6.17, or if this is
an issue.

#2.6.17 (default):
> endor:/san /net/san nfs rw,vers=3,rsize=8192,wsize=8192,hard,proto=udp,timeo=11,retrans=2,addr=endor
> hothshow:/san/show /san/show nfs rw,vers=3,rsize=32768,wsize=32768,hard,proto=tcp,timeo=600,retrans=2,addr=hothshow

#2.6.17 (specifying 'lock'):
> endor:/san /net/san nfs rw,vers=3,rsize=8192,wsize=8192,hard,proto=udp,timeo=11,retrans=2,addr=endor
> hothshow:/san/show /san/show nfs rw,vers=3,rsize=32768,wsize=32768,hard,proto=tcp,timeo=600,retrans=2,addr=hothshow

#2.6.16.44:
> endor:/san /net/san nfs rw,v3,rsize=8192,wsize=8192,hard,lock,proto=udp,addr=endor
> hothshow:/san/show /san/show nfs rw,v3,rsize=32768,wsize=32768,hard,lock,proto=tcp,addr=hothshow


Further, I've tried mounting with combinations of mount options which
seem likely candidates for affecting this bug, but have had no 
statistically significant effect:

> noac sync sync,noac,nocto nolock nocto noac,nolock,nocto

I've also compiled and added mount.nfs from nfs-utils 1.0.11 into
/sbin/mount.nfs, enabling automount to use the most recent userland tool
in case there is something "known" that was patched at that level 
recently.  No change from that in client behaviour.



3) Client usage pattern, file/dir structure.
In regards to the directory-contents/size question, they are not large.
Directly within the directory being accessed are 300 regular files
~400K in size, and three directories each with the same number/size of
files.  Files are accessed primarily out of one of the subdirs from this
point.

The most compelling piece of evidence I've tracked down so far (aside 
from the point where it was introduced) is that this bug appears to 
_only_ be triggered if there are two+ instances of the application 
running in memory acting on this directory.  I've only run a few hundred 
more test cases, but forcing only one job per host has not triggered it 
even on the "bad" kernels.  It appears (anecdotally) that jobs started a 
wildly different times (> 15 mins apart) don't seem to trigger it 
either.  That would make sense if there's some client-side timeout on 
kernel-cached entries and the TTL is expiring by the time the second job 
gets to the same phase of operation on said directory/file entries.

---
I'll be moving forward with debugging this, but considering the major 
jump in code between 2.6.16.44 and 2.6.17, I will be "inefficient at 
best" in determining which patch/major restructuring in the kernel 
instigated this and fixing it.  With most of the client nfs updates in 
2.6.17 being in the rpc_iostats and O_DIRECT write areas, those seem 
unlikely to be the cause.

Unfortunately I have yet to trigger this artificially.  Now that I know 
the trigger is a usage pattern of concurrent process accesses to a 
directory, I'll see if I can recreate the usage pattern more correctly 
after tracking the application/dir accesses with inotify/pcaps again. 
  If it's useful, I have correlated packet captures, strace logs, and 
inotify output from the data operations.  Unfortunately, all they do is 
confirm things are working properly on the wire and break at the system 
call level when the app opens files.

Let me know if after this feedback there's anything more I can provide 
directly.  I know the most useful thing I can do is provide a synthetic 
unit test for this, which I'm working on.


I greatly appreciate the questions & help.

Thanks,


/eli


Talpey, Thomas wrote:
> Say Eli, I have another question. Does this error occur mostly within
>  specific directories, and if so are they really large? Perhaps you
> could do "ls -ld <dirname>" and "ls <dirname> | wc -l" if so? If
> possible, doing these from a shell on the server itself would be best
> (I know this won't work for Ontap of course).
> 
> I'm jumping ahead, but if my suspicion is correct then the problem 
> would be coming from NFSv3 readdirplus on a huge number of files, 
> evicting other active entries in the client's cache. It's not easy to
>  turn this behavior off, but a quick test would be to use an NFSv2 
> mount, which would have other ramifications (e.g. lots more rpc's on
> the wire due to 8KB size) but would help narrow things down.
> 
> All this assumes there isn't something obvious in the mount options, 
> etc. Thanks for any info.
> 
> Tom.
> 
> At 06:19 PM 3/2/2007, Talpey, Thomas wrote:
>> :-) your first message said ENOFILE, not ENOENT! So nevermind the
>> ENFILE diagnostics.
>> 
>> What mount options are you using (cat /proc/mounts)? Also, are you
>> building custom kernels? If they're from a distro, what is the 
>> uname -a output? Is there anything interesting in dmesg?
>> 
>> This does sound like a dnlc issue (directory name cache). But there
>>  are other possibilities. A soft mount with network errors, or a 
>> server/client time skew for example can affect caching.
>> 
>> Tom.
>> 
>> At 04:58 PM 3/2/2007, Eli Stair wrote:
>>> 
>>> Still working on getting more useful debug output (MANY-layered 
>>> application run through a batch scheduler) from the system calls 
>>> themselves.  It doesn't look like the errors occur on stat()
>>> after all, but open().
>>> 
>>> The problem being an ENOENT that should NOT be occuring, as the
>>> file exists and is perfectly readable by other clients at the
>>> time of the open, as confirmed by the pcaps and other sequential
>>> successes.  This is what I am considering real breakage of the
>>> client.  Note that I've confirmed that this does not occur when
>>> accessing the same files over a local block device, only NFS.  No
>>> locks are occuring, and the file is opened read-only, so there
>>> should be no contention or reason that I
> can see.
>>> 
>>> Here's an strace of operations across several clients opening the
>>> file at the same time, showing one succeed and one fail.
>>> 
>>>> deathstar1071:/strace # cat RIB_OPENS.txt  | grep
>>>> "geom.55.rib" |
>>> grep -v stat
>>>> shot1.estair.test3strace.pid.11296:open("/path/file/geom.55.rib",
>>>> 
>>> O_RDONLY) = -1 ENOENT (No such file or directory)
>>>> shot1.estair.test3strace.pid.12115:open("/path/file/geom.55.rib",
>>>> 
>>> O_RDONLY) = 4
>>> 
>>>> deathstar1071:/strace # ls -la path/file/geom.55.rib -rw-rw----
>>>> 1 uid gid 406206 Feb 22 11:58 /path/file/geom.55.rib
>>>> 
>>> 
>>> If this were a ulimit issue for the process, it would receive an
>>> ENFILE not the ENOENT right?  It's looking like there's a
>>> disconnect in-kernel when system calls are occuring over NFS.
>>> Strangely, I left a test prog running over night just doing an
>>> open(), stat(), readc(), then close() of these same files for
>>> 5000+ iterations without reproducing the issue. So it doesn't
>>> appear to be a library issue since the call itself is returning
>>> improperly, but some usage/access pattern (above simple ops) is
>>> triggering it.
>>> 
>>> I never found what update/patch fixed the issue, but the 2.6.15
>>> fseek() bug I tracked down similarly occured over NFS only.  When
>>> performing a write into a file, then a seek and write at the
>>> head, 10%+ of the time a seek to EOF would return to the wrong
>>> byte offset.  This is seeming as fatal but more obscure.
>>> 
>>> 
>>> /eli
>>> 
>>> 
>>> 
>>> 
>>> 
>>> Talpey, Thomas wrote:
>>>> Do you mean ENFILE? If so, what's your process's file
>>>> descriptor limit (ulimit -n)? Since stat(2) doesn't open
>>>> anything, in theory it
> shouldn't
>>>> return this. fstat(2) takes a file descriptor but again,
>>>> doesn't open anything.
>>>> 
>>>> I wouldn't recommend using rpcdebug, since this is probably a
>>>> local issue. Rpcdebug will show over-the-wire stuff, mostly.
>>>> Strace will probably be the best tool.
>>>> 
>>>> Tom.
>>>> 
>>>> At 10:15 PM 3/1/2007, Eli Stair wrote:
>>>>> 
>>>>> I'm having a serious client cache issue on recent kernels.
>>>>> On 2.6.18 and 2.6.20 (but /not/ 2.6.15.4) clients I'm seeing
>>>>> periodic file
> GETATTR
>>>>> or ACCESS calls that return fine from the server pass an
>>>>> ENOFILE
> up to
>>>>> the application.  It occurs against all NFS servers I've
>>>>> tested
> (2.6.18
>>>>> knfsd, OnTap 10.0.1, SpinOS 2.5.5p8).
>>>>> 
>>>>> The triggering usage stage is repeated stat'ing of a several
>>>>> hundred files that are opened read-only (but not close() or
>>>>> open()'ing it
> again)
>>>>> during runtime.  I have been unable to duplicate the usage
>>>>> into a bug-triggering testcase yet, but it is very easily
>>>>> triggered by an internal app.  Mounting the NFS filesystems
>>>>> with 'nocto' appears to mitigate the issue by about 50%, but
>>>>> does not completely get rid
> of it.
>>>>> Also, using 2.6.20+ Trond's NFS_ALL patches and this one you
>>>>> 
> supplied
>>>>> also slow the rate of errors, but not completely.
>>>>> 
>>>>> I'm rigging the application with an strace harness so I can
>>>>> track
> down
>>>>> specifically what ops are failing in production.  I can
>>>>> confirm that those errors I have witnessed under debug are
>>>>> NOT failing due to
> an NFS
>>>>> call returning where access is denied, or on an open(), it
> appears to be
>>>>> stat() of the file (usually several dozen or hundreds in
> sequence) that
>>>>> return ENOFILE, though the call should return sucess.
>>>>> 
>>>>> Any tips on using rpcdebug effectively?  I'm getting
>>>>> tremendous
> levels
>>>>> of info output with '-m nfs -s all', too much to parse well.
>>>>> 
>>>>> I'll update with some more hard data as I get further along,
>>>>> but
> want to
>>>>> see if a) anyone else has noticed this and working on a fix,
>>>>> and
> b) if
>>>>> there are any suggestions on getting more useful data than
>>>>> what I'm working towards.
>>>>> 
>>>>> Reverting to 2.6.15.4 (which doesn't exhibit this particular
>>>>> bug)
> isn't
>>>>> a direct solution even temporarily, as that has a nasty NFS
>>>>> fseek bug (seek to EOF goes to wrong offset).
>>>>> 
>>>>> Cheers,
>>>>> 
>>>>> 
>>>>> /eli
>>>> 
>>>> 
>>> 
>>> 
>>> -------------------------------------------------------------------------
>>>  Take Surveys. Earn Cash. Influence the Future of IT Join
>>> SourceForge.net's Techsay panel and you'll get the chance to
> share your
>>> opinions on IT & business topics through brief surveys-and earn
>>> cash 
>>> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
>>> 
> <http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV>
> 
>>> _______________________________________________ NFS maillist  -
>>> NFS@lists.sourceforge.net 
>>> https://lists.sourceforge.net/lists/listinfo/nfs
>> 
>> 
>> -------------------------------------------------------------------------
>>  Take Surveys. Earn Cash. Influence the Future of IT Join
>> SourceForge.net's Techsay panel and you'll get the chance to
> share your
>> opinions on IT & business topics through brief surveys-and earn
>> cash 
>> http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
>> 
> <http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV>
> 
>> _______________________________________________ NFS maillist  -
>> NFS@lists.sourceforge.net 
>> https://lists.sourceforge.net/lists/listinfo/nfs
> 
> 


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
