From: Daniel J Blueman <daniel.blueman@gmail.com>
Subject: Re: regression, bisected: getcwd() ENOENT on NFS4...
Date: Wed, 4 Nov 2009 09:36:45 +0000
Message-ID: <6278d2220911040136m4cadc0f5sb71b8306bf02fc5b@mail.gmail.com>
References: <6278d2220910251631j40caec00lf2dee6159947d983@mail.gmail.com>
	 <1256563190.3742.4.camel@heimdal.trondhjem.org>
	 <6278d2220911010447v5889b9bbt33f685ef7669cc45@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux Kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754859AbZKDJgo@vger.kernel.org>
In-Reply-To: <6278d2220911010447v5889b9bbt33f685ef7669cc45@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Nov 1, 2009 at 12:47 PM, Daniel J Blueman
<daniel.blueman@gmail.com> wrote:
> Hi Trond,
>
> On Mon, Oct 26, 2009 at 1:19 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
>> On Sun, 2009-10-25 at 23:31 +0000, Daniel J Blueman wrote:
>>> Since 2.6.30-rc, I've been experiencing various issues relating to
>>> getcwd() returning ENOENT on NFS4 clients. I used an over-complicat=
ed
>>> but reliable reproducer [1] (on Karmic RC against a 2.6.32-rc5 NFS4
>>> server) to bisect [2].
>>>
>>> The impact of this regression is moderate (side-effects range from
>>> benign to failure), so we should get a fix into 2.6.32 if at all
>>> possible and strongly consider a 2.6.31 stable update.
>>>
>>> Thanks,
>>> =A0 Daniel
>>>
>>> --- [1]
>>>
>>> $ apt-get source apt
>>> $ cd apt-*
>>> $ ./configure && make
>>> [snip]
>>> sh: getcwd() failed: No such file or directory
>>>
>>> --- [2]
>>>
>>> a65318bf3afc93ce49227e849d213799b072c5fd is first bad commit
>>> commit a65318bf3afc93ce49227e849d213799b072c5fd
>>> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
>>> Date: =A0 Wed Mar 11 14:10:28 2009 -0400
>>>
>>> =A0 =A0 NFSv4: Simplify some cache consistency post-op GETATTRs
>>
>> I'm having a lot of trouble seeing how this patch could result in
>> ENOENT. All it should be doing is reducing the frequency with which =
we
>> update some of the inode metadata.
>>
>> Have you ever been able to capture one of these errors using strace?
>
> Backing this patch out by hand against stock 2.6.32-rc5 (w/ 2.6.32-rc=
5
> on server) corrects the behaviour. It's readily reproducible [1];
> using 2.6.30, the issue is not seen, thus is a regression.
>
> To observe the change to user-level behaviour (after the reproducer c=
ommands):
> # make clean
> # strace -ffe getcwd make -n >list
> [pid =A03829] getcwd(0x7fffa269a380, 4096) =3D -1 ENOENT (No such fil=
e or directory)
> make: getcwd: No such file or directory
>
> Would this help for me to log this via a bugzilla.kernel.org ticket?
>
> Thanks,
> =A0Daniel
>
> --- [1]
>
> booting eg:
> http://mira.sunsite.utk.edu/ubuntu-releases/karmic/ubuntu-9.10-deskto=
p-amd64.iso
>
> $ sudo bash
> # apt-get install build-essential
> # apt-get build-dep apt
> # mount server:/ /mnt -tnfs4 && cd /mnt
> # apt-get source apt
> # cd apt-0.7.23.1ubuntu2
> # ./configure && make
> =A0-> "getcwd: No such file or directory" messages observed with cite=
d
> patch and not without

=46or continuity with the mailing list thread, I've created a bug repor=
t
of this at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D14541
--=20
Daniel J Blueman
