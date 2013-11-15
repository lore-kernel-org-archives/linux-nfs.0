Return-Path: linux-nfs-owner@vger.kernel.org
Received: from out03.mta.xmission.com ([166.70.13.233]:59924 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752097Ab3KOFFo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Nov 2013 00:05:44 -0500
From: ebiederm@xmission.com (Eric W. Biederman)
To: Jeff Layton <jlayton@redhat.com>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        Greg KH <gregkh@linuxfoundation.org>, <linux-kernel@vger.kernel.org>,
        <linux-fsdevel@vger.kernel.org>, <linux-nfs@vger.kernel.org>,
        <devel@openvz.org>, <oleg@redhat.com>, <bfields@fieldses.org>,
        <bharrosh@panasas.com>
References: <20131111071825.62da01d1@tlielax.poochiereds.net>
	<20131112004703.GB15377@kroah.com>
	<20131112061201.04cf25ab@tlielax.poochiereds.net>
	<528226EC.4050701@parallels.com>
	<20131112083043.0ab78e67@tlielax.poochiereds.net>
Date: Thu, 14 Nov 2013 21:05:29 -0800
In-Reply-To: <20131112083043.0ab78e67@tlielax.poochiereds.net> (Jeff Layton's
	message of "Tue, 12 Nov 2013 08:30:43 -0500")
Message-ID: <87d2m2w8yu.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Subject: Re: call_usermodehelper in containers
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> writes:

> On Tue, 12 Nov 2013 17:02:36 +0400
> Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:
>
>> 12.11.2013 15:12, Jeff Layton пишет:
>> > On Mon, 11 Nov 2013 16:47:03 -0800
>> > Greg KH <gregkh@linuxfoundation.org> wrote:
>> >
>> >> On Mon, Nov 11, 2013 at 07:18:25AM -0500, Jeff Layton wrote:
>> >>> We have a bit of a problem wrt to upcalls that use call_usermodehelper
>> >>> with containers and I'd like to bring this to some sort of resolution...
>> >>>
>> >>> A particularly problematic case (though there are others) is the
>> >>> nfsdcltrack upcall. It basically uses call_usermodehelper to run a
>> >>> program in userland to track some information on stable storage for
>> >>> nfsd.
>> >>
>> >> I thought the discussion at the kernel summit about this issue was:
>> >> 	- don't do this.
>> >> 	- don't do it.
>> >> 	- if you really need to do this, fix nfsd
>> >>
>> >
>> > Sorry, I couldn't make the kernel summit so I missed that discussion. I
>> > guess LWN didn't cover it?
>> >
>> > In any case, I guess then that we'll either have to come up with some
>> > way to fix nfsd here, or simply ensure that nfsd can never be started
>> > unless root in the container has a full set of a full set of
>> > capabilities.
>> >
>> > One sort of Rube Goldberg possibility to fix nfsd is:
>> >
>> > - when we start nfsd in a container, fork off an extra kernel thread
>> >    that just sits idle. That thread would need to be a descendant of the
>> >    userland process that started nfsd, so we'd need to create it with
>> >    kernel_thread().
>> >
>> > - Have the kernel just start up the UMH program in the init_ns mount
>> >    namespace as it currently does, but also pass the pid of the idle
>> >    kernel thread to the UMH upcall.
>> >
>> > - The program will then use /proc/<pid>/root and /proc/<pid>/ns/* to set
>> >    itself up for doing things properly.
>> >
>> > Note that with this mechanism we can't actually run a different binary
>> > per container, but that's probably fine for most purposes.
>> >
>> 
>> Hmmm... Why we can't? We can go a bit further with userspace idea.
>> 
>> We use UMH some very limited number of user programs. For 2, actually:
>> 1) /sbin/nfs_cache_getent
>> 2) /sbin/nfsdcltrack
>> 
>
> No, the kernel uses them for a lot more than that. Pretty much all of
> the keys API upcalls use it. See all of the callers of
> call_usermodehelper. All of them are running user binaries out of the
> kernel, and almost all of them are certainly broken wrt containers.

Broken in the sense that we don't run them in the container yes.

I tried using the keys api for the uid mapping of containers and I wound
up being very disappointed because for testing/debugging I could never
flush any result I had ever returned a key for.  Which rather soured me
on the real-world usability of the key based user mode helpers.  Perhaps
I was doing it wrong but it seemed like a very brittle interface, that
was intollerant of human failures.

>> If we convert them into proxies, which use /proc/<pid>/root and /proc/<pid>/ns/*, this will allow us to lookup the right binary.
>> The only limitation here is presence of this "proxy" binaries on "host".
>> 
>
> Suppose I spawn my own container as a user, using all of this spiffy
> new user namespace stuff. Then I make the kernel use
> call_usermodehelper to call the upcall in the init_ns, and then trick
> it into running my new "escape_from_namespace" program with "real" root
> privileges.
>
> I don't think we can reasonably assume that having the kernel exec an
> arbitrary binary inside of a container is safe. Doing so inside of the
> init_ns is marginally more safe, but only marginally so...

One thing we have done with the core dump helper is because there is
enough information to know the namespaces of the program dumping core
have the root owned and installed helper use setns to get inside the
namespaces so we can have a per namespace core dump policy.

If we can provide enough context to the other helpers that is probably
the easiest way to go.

The question is can we truly pass enough state.

>> And we don't need any significant changes in kernel.
>> 
>> BTW, Jeff, could you remind me, please, why exactly we need to use UMH to run the binary?
>> What are this capabilities, which force us to do so?
>> 
>
> Nothing _forces_ us to do so, but upcalls are very difficult to handle,
> and UMH has a lot of advantages over a long-running daemon launched by
> userland.
>
> Originally, I created the nfsdcltrack upcall as a running daemon called
> nfsdcld, and the kernel used rpc_pipefs to communicate with it.
>
> Everyone hated it because no one likes to have to run daemons for
> infrequently used upcalls. It's a pain for users to ensure that it's
> running and it's a pain to handle when it isn't. So, I was encouraged
> to turn that instead into a UMH upcall.
>
> But leaving that aside, this problem is a lot larger than just nfsd. We
> have a *lot* of UMH upcalls in the kernel, so this problem is more
> general than just "fixing" nfsd's.

Yes.

So far I don't think we can trigger any of these upcalls from inside of
a user namespace so we aren't in trouble yet.  But it is definitely
worth looking at.   Because we are basically one person scratching their
itch to get some feature working from being at the point where nfs or
something else that uses the upcalls needs the support.

Eric
