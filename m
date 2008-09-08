From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: [NFS] blocks of zeros (NULLs) in NFS files in kernels >= 2.6.20
Date: Mon, 8 Sep 2008 17:15:57 -0400
Message-ID: <76bd70e30809081415h6b55a8dfl8171634c576ac946@mail.gmail.com>
References: <20080905191939.GG22796@merfinllc.com>
	 <0A24B45A-9761-4310-B1DB-B4738964E862@oracle.com>
	 <20080908190212.GF28123@merfinllc.com>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Neil Brown" <neilb@suse.de>,
	"Linux NFS Mailing List" <linux-nfs@vger.kernel.org>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"LKML Kernel" <linux-kernel@vger.kernel.org>
To: "Aaron Straus" <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rn-out-0910.google.com ([64.233.170.191]:20364 "EHLO
	rn-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753612AbYIHVQA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Sep 2008 17:16:00 -0400
Received: by rn-out-0910.google.com with SMTP id k40so273720rnd.17
        for <linux-nfs@vger.kernel.org>; Mon, 08 Sep 2008 14:15:58 -0700 (PDT)
In-Reply-To: <20080908190212.GF28123-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 8, 2008 at 3:02 PM, Aaron Straus <aaron-bYFJunmd+ZV8UrSeD/g0lQ@public.gmane.org> wrote:
> On Sep 05 03:56 PM, Chuck Lever wrote:
>> Comparing a wire trace with strace output, starting with the writing
>> client, might also be illuminating.  We prefer wireshark as it uses
>> good default trace settings, parses the wire bytes and displays them
>> coherently, and allows you to sort the frames in various useful ways.
>
> OK in addition to the bisection I've collected trace data for the good
> (commit 4d770ccf4257b23a7ca2a85de1b1c22657b581d8) and bad (commit
> e261f51f25b98c213e0b3d7f2109b117d714f69d) cases.
>
> Attached is a file called trace.tar.bz2 inside you'll find 4 files, for
> the two sessions:
>
>  bad-wireshark
>  bad-strace
>
>  good-wireshark
>  good-strace
>
> From a quick glance the difference seems to be the bad case does an
> UNSTABLE NFS WRITE call.  I don't really know what that means or what
> its semantics are... but that bad commit does seem to introduce this
> regression.

A little analysis reveals the bad behavior on the wire.  I filtered
the network traces for just WRITE requests.  There were six in the
good trace, and five in the bad.  This seems to correspond with the
strace logs, which show that you stopped the bad run before it
generated more writes.

Good:

time:           offset:         len:    sync:           byte range:
 35.402734      0               8000    FILE_SYNC       [0,     7999]
100.405170      4096            11904   FILE_SYNC       [4096,  15999]
160.407822      12288           7712    FILE_SYNC       [12288, 19999]
195.411035      16384           11616   FILE_SYNC       [16384, 27999]
260.413574      24576           11424   FILE_SYNC       [24576, 35999]
295.704044      32768           7232    FILE_SYNC       [32768, 39999]

Bad:

time:           offset:         len:    sync:           byte range:
 36.989907      0               8000    FILE_SYNC       [0,     7999]
101.991164      4096            11904   FILE_SYNC       [4096,  15999]
161.992447      12288           7712    FILE_SYNC       [12288, 19999]
166.992203      20480           3520    UNSTABLE        [20480, 23999]
169.181642      16384           4096    FILE_SYNC       [16384, 20479]

The first thing I notice is that the client is re-writing areas of the
file.  It seems to want to generate page aligned WRITEs, but this
means it writes over bytes that were already sent to the server.
Probably not the issue here, but that's certainly not optimal
behavior.  The strace logs show that the application generates 4000
byte write(2) calls, without any operation interleaved that might
change the seek offset.

I might go so far to say that this is incorrect behavior as multiple
clients writing to a file not on page boundaries would clobber each
other's WRITEs.

The second thing is that UNSTABLE WRITE.  The fact that it is UNSTABLE
is not the problem here.  The byte range is what is most interesting:
it leaves a hole in the file, which is fixed by the next write (3
seconds later) which fills in that hole.

Normally this isn't a big deal, as NFS likes applications to serialize
access to shared files.  However, in this case we expect the .flush()
to force all dirty bytes out at once, and this is definitely not
occurring....

The third thing is that I don't see any flush or fsync system calls in
the strace logs, even though the writer.py script invokes fp.flush().
I'm not terribly familiar with Python's flush().  How do you expect
the flush() method to work?

I wonder why the client is using FILE_SYNC writes and not
UNSTABLE+COMMIT. Are the clients using the "sync" mount option?  I
don't see O_SYNC on the open.

  open("test-nfs", O_WRONLY|O_CREAT|O_TRUNC|O_LARGEFILE, 0666) = 3

I think I saw some recent work in Trond's development branch that
makes some changes in this area.  I will wait for him to respond to
this thread.

--
Chuck Lever
