Return-Path: <tibbs@math.uh.edu>
From: Jason L Tibbitts III <tibbs@math.uh.edu>
To: "Benjamin Coddington" <bcodding@redhat.com>
Cc: "Michael Sterrett" <michael@sterretts.net>,  linux-nfs@vger.kernel.org
Subject: Re: f30cb757f680f965ba8a2e53cb3588052a01aeb5 regression
References: <CA+rTEUMDy-Okdpo1EuWHS5n_6HAm5RKa4OVHPQPddRLP4hdtxw@mail.gmail.com>
	<B4CA251B-5BE1-4D57-B4EC-990AAE7F4AAE@redhat.com>
Date: Wed, 20 Sep 2017 17:12:44 -0500
In-Reply-To: <B4CA251B-5BE1-4D57-B4EC-990AAE7F4AAE@redhat.com> (Benjamin
	Coddington's message of "Wed, 20 Sep 2017 08:13:13 -0400")
Message-ID: <ufao9q5aujn.fsf@epithumia.math.uh.edu>
MIME-Version: 1.0
Content-Type: text/plain
List-ID: <linux-nfs.vger.kernel.org>

>>>>> "BC" == Benjamin Coddington <bcodding@redhat.com> writes:

BC> Hi Michael, can you clarify what you mean by "client machine locks
BC> up"?  Are you receiving reports of a hung task in the kernel logs?

I'll chime in to say that I'm seeing something which may potentially
related that I haven't been able to spend the time to track down
properly.  Basically, I can make NFS hang just by editing a file with
vim on the client.  When I attempt to write the file, the vim process
goes into the 'D' state, probably trying to do some sort of locking (as
I have a lot of stuff running inside of vim).  I think this may require
that you not have write permissions on the directory containing the file
I'm editing, so that vim is forced to write backups or do locking or
something back in my NFS-mounted home directory.

Once this happens, the server actually gets into an odd state.  I have
seen vim instances running on the server hang (probably trying to lock a
file) until the client is rebooted.  And even after the client is
rebooted, it still can't mount anything from the server.  Instead the
mount call itself just hangs, along with a kernel thread named
"[172.21.86.85-ma]".  This state will persist until the server itself is
rebooted.

Server: Fedora 26, kernel 4.12.9 (need to reboot into 4.12.13 soon).
Clients: Fedora 25, various 4.11.X and 4.12.X.

All mounts are via NFS4.2/krb5i.

I think this might have come in when I updated this server to something
in the 4.12 kernel series but I'm not completely sure at this point.

 - J<
