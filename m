From: Dax Kelson <dax@gurulabs.com>
Subject: Re: [PATCH] Secure user authentication for NFS using RPCSEC_GSS
 [0/6]
Date: Mon, 13 Jan 2003 11:06:40 -0700 (MST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0301131052440.20523-100000@mooru.gurulabs.com>
References: <Pine.LNX.4.44.0301130745510.26185-100000@dunlop.admin.ie.alphyra.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trond.myklebust@fys.uio.no,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	NFS maillist <nfs@lists.sourceforge.net>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Paul Jakma <paulj@alphyra.ie>
In-Reply-To: <Pine.LNX.4.44.0301130745510.26185-100000@dunlop.admin.ie.alphyra.com>
List-ID: <nfs.lists.sourceforge.net>

On Mon, 13 Jan 2003, Paul Jakma wrote:

> On 12 Jan 2003, Dax Kelson wrote:
> 
> > Standard NFS security/authentication sucks rocks. Without this NFS home
> > directory servers are just waiting to be ransacked by a rouge (or
> > compromised) root user on a client machine.
> 
> AIUI, A root user still can. The users krbv5 credentials will
> generally have been cached to storage. (though i suppose one could
> mount that storage via NFS and use root_squash, but that's little 
> protection.).

Well, I was trying to keep my email short. Yes, if you login to a 
compromised machine, and then obtain krbv5 credentails the evil root user 
can access/delete/modify your files stored on a RPSEC_GSS NFS server.

With RPSEC_GSS, a compromised machine, on it's own (no logged in users
except evil root), can not access/delete/modify files stored on the NFS
home directory server, which is quite different than the normal case. This 
helps when the exploit-of-the-day hits at 4am Saturday morning.

As a matter of practice you shouldn't leave cached credentials lying
around when you not logged in. Unless you have a very strong reason not
to, kill your ssh-agent and run kdestory on logout (.bash_logout and 
friends).

Dax
