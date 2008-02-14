From: Nix <nix@esperi.org.uk>
Subject: Re: Upgrade to 2.6.24 breaks NFS service
Date: Thu, 14 Feb 2008 00:14:50 +0000
Message-ID: <878x1ojsw5.fsf@hades.wkstn.nix>
References: <87lk5pjkro.fsf@hades.wkstn.nix>
	<20080213021912.b127c4a7.akpm@linux-foundation.org>
	<20080213075738.086f7b32@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934424AbYBNAPv@vger.kernel.org>
In-Reply-To: <20080213075738.086f7b32@barsoom.rdu.redhat.com> (Jeff Layton's message of "Wed, 13 Feb 2008 07:57:38 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 13 Feb 2008, Jeff Layton told this:

> If upgrading nfs-utils doesn't help, on this box, could you run:
>
> # rpcinfo -p localhost
>
> send the output? statd expects that lockd will always be listening on a
> UDP socket and some changes recently made it so that when there are
> only TCP mounts that it doesn't necessarily do so. That may be the
> problem here.

I rebooted back into 2.6.24.2 again, and everything works now, without
even upgrading nfs-utils (although I did that anyway, to nfs-utils git
head, and it's still happy).

Linux: debugs itself, no human intervention required! :)



(The inconsistency of this screams `port allocation' to me. If it
happens again I'll get some rpcinfo output and packet dumps. I'd
have done it this time if it hadn't been for the plug-the-security-
hole rush and it being 2am.)

-- 
`The rest is a tale of post and counter-post.' --- Ian Rawlings
                                                   describes USENET
