From: devzero@web.de
Subject: =?iso-8859-15?q?uuid/blkid_performance_problem_with_large_n?=
 =?iso-8859-15?q?umber_of_mounts_-_was=3A_Re=3A__stale_nfs_file_handle_wit?=
 =?iso-8859-15?q?h_exported_loopback_mounts?=
Date: Tue, 13 Nov 2007 23:44:47 +0100
Message-ID: <2083621400@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
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

since i posted 2 problems in one mail - and one problem is solved now, for =
the second problem i have opened a ticket at =


http://sourceforge.net/tracker/index.php?func=3Ddetail&aid=3D1831403&group_=
id=3D14&atid=3D100014  =

( uuid/blkid performance problem with large number of mounts )

so this won`t get lost.

regards
roland


> -----Urspr=FCngliche Nachricht-----
> Von: devzero@web.de
> Gesendet: 02.11.07 20:06:58
> An: Neil Brown <neilb@suse.de>
> CC: "J. Bruce Fields" <bfields@fieldses.org>, NFS@lists.sourceforge.net
> Betreff: Re: [NFS] stale nfs file handle with exported loopback mounts


> =

> hi!
> =

> it seems i was having weird mail problems with sending mails trough my we=
bmailer - at least two followups with attachments seem to be lost on sendin=
g and are not in my sent folder anymore....
> =

> anyway - here is a second try, but probably worse than what i have writte=
n before :)
> =

> =

> first off, thanks for the patch Neil, things look _much_ better now and e=
xporting loopback mounts now basiscally works again.
> nice to see that my posting helped finding bugs.
> =

> maybe i have two more bugs for you :)
> =

> i have loopback mounts on the server and exported the parent dir with cro=
ssmnt option.
> =

> after mounting for the first time on the client, i`m getting "Invalid arg=
ument" for each loopback-mounted dir, if i do an ls -la on /mnt.
> this only happens _once_ and seems to be a server problem, because i can =
reboot the client and remount , i never see that errors again.
> =

> besides that, all seems to work fine.
> =

> as neil suggested, i have made a tcpdump of this available at:
> http://82.141.46.148/bugs/nfs/tcpdump.out.bz2
> =

> =

> furthermore, there is a very strange performance issue i was able to trac=
k down to uuid/blkid support.
> =

> i recognized this issue when i exported a directory containing a very lar=
ge number of loopback mounts via crossmnt export option.
> ls -la on the clients mountpoint seemed to hung and i could see mountd be=
ing busy, eating 100% cpu for quite a while.
> =

> the time needed for ls to finish seems to grow exponentially with the num=
ber of loopback-mounts inside the exported directory - i also tried with 10=
00 loopback mounts and mountd being busy for several minutes with this.
> =

> i have made a strace of mountd available at:
> http://82.141.46.148/bugs/nfs/mountd.strace.txt.bz2
> =

> you can see that mountd seems to be busy doing the same things over and o=
ver again, looks that it does stat64() for all devices in /etc/blkid.tab fo=
r each loopback mount, weird.
> =

> here is some "strace -c -p $PID_OF_MOUNTD" for comparison -  without uuid=
/blkid support compiled in it looks like this:
> =

> % time     seconds  usecs/call     calls    errors syscall
> ------ ----------- ----------- --------- --------- ----------------
>  73.23    0.147722           2     66313           stat64
>  10.37    0.020923          20      1031           write
>   5.54    0.011179          23       494           select
>   3.82    0.007699           5      1546           read
>   3.04    0.006137           8       773           time
>   2.18    0.004393           6       769           lstat64
>   1.08    0.002182           4       519           munmap
>   0.40    0.000797           1      1035           close
>   0.29    0.000594           1      1034           open
>   0.04    0.000089           0      1036           fstat64
>   0.00    0.000000           0         2           alarm
>   0.00    0.000000           0         3           _llseek
>   0.00    0.000000           0         1           fdatasync
>   0.00    0.000000           0         2           poll
>   0.00    0.000000           0         2           rt_sigaction
>   0.00    0.000000           0       521           mmap2
>   0.00    0.000000           0         2           fcntl64
>   0.00    0.000000           0         1           socket
>   0.00    0.000000           0         1           connect
>   0.00    0.000000           0         1           accept
>   0.00    0.000000           0         2           send
> ------ ----------- ----------- --------- --------- ----------------
> 100.00    0.201715                 75088           total
> =

> =

> =

> this is an strace -c when uuid/blkid support is being compiled in:
> =

> % time     seconds  usecs/call     calls    errors syscall
> ------ ----------- ----------- --------- --------- ----------------
>  61.64    1.008158           2    550916           stat64
>  21.67    0.354441           9     37662           read
>   5.65    0.092476          15      6377           getdents64
>   4.06    0.066381           3     21395      8232 open
>   1.62    0.026485           2     13169           fstat64
>   1.36    0.022237           2     13164           close
>   1.22    0.020025           2      8414           lstat64
>   1.15    0.018805           4      4415           munmap
>   0.27    0.004382          17       258           rename
>   0.26    0.004329          17       258           unlink
>   0.26    0.004305           2      2101           write
>   0.23    0.003786           1      4380           fcntl64
>   0.18    0.002899          11       262           select
>   0.18    0.002883          11       258           access
>   0.11    0.001857           0      4417           mmap2
>   0.11    0.001765           0      4652           time
>   0.01    0.000237           1       258           link
>   0.00    0.000041           0       258           lseek
>   0.00    0.000000           0         2           alarm
>   0.00    0.000000           0         2           brk
>   0.00    0.000000           0         1           gettimeofday
>   0.00    0.000000           0       258           fchmod
>   0.00    0.000000           0       265           _llseek
>   0.00    0.000000           0         1           fdatasync
>   0.00    0.000000           0         2           poll
>   0.00    0.000000           0         1           prctl
>   0.00    0.000000           0         2           rt_sigaction
>   0.00    0.000000           0         1           getuid32
>   0.00    0.000000           0         1           getgid32
>   0.00    0.000000           0         1           geteuid32
>   0.00    0.000000           0         1           getegid32
>   0.00    0.000000           0         1           futex
>   0.00    0.000000           0         1           socket
>   0.00    0.000000           0         1           connect
>   0.00    0.000000           0         1           accept
>   0.00    0.000000           0         2           send
> ------ ----------- ----------- --------- --------- ----------------
> 100.00    1.635492                673158      8232 total
> =

>  =

> as you can see there is an unusual high number of stat64() calls
> =

> server is opensuse 10.3 , client is suse 9.3 professional
> =

> if i can help resolving this issue, tell me what to do :)
> =

> regards
> roland
> =

> =

> =

> > -----Urspr=FCngliche Nachricht-----
> > Von: Neil Brown <neilb@suse.de>
> > Gesendet: 01.11.07 05:26:50
> > An: devzero@web.de
> > CC: "J. Bruce Fields" <bfields@fieldses.org>, NFS@lists.sourceforge.net
> > Betreff: Re: [NFS] stale nfs file handle with exported loopback mounts
> =

> =

> > =

> > On Wednesday October 31, devzero@web.de wrote:
> > > ok, i just wanted to tell that this isn`t the right way to go imho.
> > > =

> > > some time ago i have tested exporting a parent dir containing
> > > several loopback mounted iso images with some pre-1.1.0 nfs-utils
> > > version and it worked - so =EC wonder why it now seems to have issues
> > > as things should have gone stable..... =

> > =

> > We have a way of breaking things sometimes.... It's called
> > "progress". :-)
> > =

> > The short answer is that there is a bug in mountd which is fixed by
> > this patch:
> > =

> > diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
> > index ce1a5a9..fd317cd 100644
> > --- a/utils/mountd/cache.c
> > +++ b/utils/mountd/cache.c
> > @@ -508,7 +508,7 @@ void nfsd_fh(FILE *f)
> >  	 */
> >  	qword_printint(f, 0x7fffffff);
> >  	if (found)
> > -		qword_print(f, found->e_path);
> > +		qword_print(f, found_path);
> >  	qword_eol(f);
> >   out:
> >  	free(found_path);
> > =

> > =

> > The longer answer is that there is also a bug in "mount.nfs" which is
> > unrelated but was slowing me down in chasing this bug, and there is
> > also a bug in the NFS client which was causing my client oops and need
> > a reboot every time I triggered this bug in mountd, which further
> > slowed me down.
> > =

> > The effect of this bug in mountd is that when the NFS client calls
> > GETATTR on the root of the subordinate filesystem (e.g. your
> > loop-mounted isos), it got attr information about the parent. ie. the
> > top-level exported filesystem (/export in your case I think).
> > This has a different 'fsid' than the nfs client was expecting and
> > the NFS client got confused in various ways.
> > =

> > Thanks for your problem report - it helped find 3 bugs!
> > =

> > I'll get proper patches or bug report off to the relevant maintainers
> > shortly.
> > =

> > NeilBrown
> > =

> =

> =



______________________________________________________________________
XXL-Speicher, PC-Virenschutz, Spartarife & mehr: Nur im WEB.DE Club!		=

Jetzt testen! http://produkte.web.de/club/?mc=3D021130


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
