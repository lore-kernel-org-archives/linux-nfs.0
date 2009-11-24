From: Peter Staubach <staubach@redhat.com>
Subject: Re: [nfs-utils PATCH] retry on EPERM from NFSv4 mount attempt
Date: Tue, 24 Nov 2009 16:58:29 -0500
Message-ID: <4B0C5705.6030608@redhat.com>
References: <19211.7054.291514.185591@notabene.brown>	<4B0BEDDB.1010203@RedHat.com>	<20091124205616.GB29856@fieldses.org> <20091125085122.316f4eb3@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39937 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933909AbZKXV6b (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Nov 2009 16:58:31 -0500
In-Reply-To: <20091125085122.316f4eb3-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Neil Brown wrote:
> On Tue, 24 Nov 2009 15:56:16 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
>> On Tue, Nov 24, 2009 at 09:29:47AM -0500, Steve Dickson wrote:
>>>>  So I think we need to fall back on EPERM as well.  See below.
>>> I already posted this patch on the v4 mailing list
>>> http://linux-nfs.org/pipermail/nfsv4/2009-November/011595.html
>>> but it got shot down...  at least that's how I interpreted the
>>> responses... 
> 
> Thanks for the reference ... clearly I am not keeping up with my
> nfs mailing lists....
> 
> 
>>> But I do thing we need this, since there are so many server 
>>> that will simple break if we don't... Agreed?
> 
> Agreed that we certainly need something.  We cannot expect people to
> reconfigure their servers because they installed new software on the
> client.
> 
>> My position is that servers should either a) turn off NFSv4 or b) add
>> a pseudoroot, and that we should modify initscripts to make this
>> harder to screw up.
> 
> In the ideal world, yes.  Maybe this is best done in the kernel?
> Can we synthesis an RPC-protocol-not-supported error if and NFSv4
> request arrives from a client for which no pseudo-root is configured?
> 
>> (For now (without automatic pseudoroot creation) we should by default
>> be running rpc.nfsd with -N 4; and adding the v4 support should be
>> something administrators do when they add a pseudoroot.)
> 
> Hind sight is 20/20 they say.  We probably should have done this, but
> I think it is now too late to do anything useful in the init scripts.
> 
>> ((If this is really totally unfeasible, then I should quickly cue up a
>> revert for the patch I have queued for 2.6.33 which changes this error
>> again, to SERVERFAULT....))
> 
> Maybe - maybe not.
> 
> The situation on the client is that for a command that has
> traditionally always performed a v3 or (before that) a v2 mount, we are
> now trying a v4 mount.
> I see that v4 attempt as opportunistic.  If anything goes wrong I think
> it is reasonable to go back to "the old way".
> 
> So I think this piece of code in mount.nfs should retry on any error at
> all, so it would not matter whether you change again to SERVERFAULT.
> 
> But I think the best fix for the kernel is to get nfsd4_proc_compound
> to return RPC_PROG_MISMATCH if there is no pseudo root, and then get
> svc_process_common to handle this and fake up appropriate min/max
> version numbers.
> 

I think that we might be better off in the long run by taking a
step back and getting all of the plumbing right, instead of
cluttering up things to have knowledge which they have no
business knowing or worrying about.

If the NFSv4 server gets a request which involves the root file
handle and one has not been defined, then it should return the
error that is defined by the protocol.  What the client chooses
to do with the error is up to it.

		ps
