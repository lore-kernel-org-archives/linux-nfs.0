From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [basic] nfsd failing to start
Date: Mon, 12 Jan 2009 22:34:56 -0500
Message-ID: <20090113033456.GA15650@fieldses.org>
References: <87zlhxy102.fsf@newsguy.com> <20090112172418.GC24322@fieldses.org> <54FED3E6-80D0-4D45-A295-1C2CE2F9DA56@oracle.com> <20090112222905.GI1834@fieldses.org> <81C79F78-751B-405C-BF61-9FFD903909A3@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:33146 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754749AbZAMDe6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jan 2009 22:34:58 -0500
In-Reply-To: <81C79F78-751B-405C-BF61-9FFD903909A3@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 12, 2009 at 06:04:59PM -0500, Chuck Lever wrote:
> On Jan 12, 2009, at 5:29 PM, J. Bruce Fields wrote:
>> None of this is in contradiction to what you've said--it's a
>> tradeoff--but on balance I'd prefer the additional svc_register()  
>> logic.
>
> We really do want a hard switch to be able to turn this new feature off.
>
> It's impossible for the kernel to detect which version of rpcbind is  
> running.  Yes, it can tell if rpcbind v4 is supported or not, but what  
> if some versions of rpcbind have a bug or exhibit some incompatible or  
> undesirable behavior?  We have already required an incompatible rev of  
> rpcbind once in the last six months because of bugs.

I'd consider that acceptable; we just use the highest protocol version,
and deal with the problem of buggy userspace separately.

> Because we have to support distributions like Ubuntu and Debian, which  
> package basically what is in upstream without a lot of testing, we have 
> to allow them to flip a switch to get the desired legacy behavior, while 
> still permitting users who want to experiment to do so without a lot of 
> trouble.  It's also in the best interest of our kernel community which 
> you mention above.

Another way users and distributors could flip that switch would be by
varying the choice of userland daemon to install and run.  Then flipping
the switch would not require a kernel change.

> Transitioning user space will be an effort for all distributions.  This 
> CONFIG switch was added so they could do that without worrying about 
> their existing NFS implementation suddenly breaking after a kernel 
> upgrade.  When/if it does misbehave, it is simply a matter of disabling 
> one config option to restore order.

"apt-get remove rpcbind", for example, will often be more convenient
than replacing the kernel.

> It would probably be easy to add some logic that detects a protocol  
> version mismatch, and then prints a clearer error message.  That's what I 
> had in mind to address bz 12256.  But this is never going to be perfect 
> while user space IPv6 support is under development and in transition.

Thanks, I agree that that would be an improvement.

I can't demand the runtime protocol-version switching at this point.  I
still would consider it a further improvement, though, if someone had
the time to work on it.

--b.
