From: Ian Kent <raven@themaw.net>
Subject: Re: nested mounts -- supported?
Date: Thu, 28 Apr 2005 16:47:48 +0800 (WST)
Message-ID: <Pine.LNX.4.58.0504281639350.14881@wombat.indigo.net.au>
References: <17008.3537.313570.647302@segfault.boston.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: autofs mailing list <autofs@linux.kernel.org>, nfs@lists.sourceforge.net
Return-path: <autofs-bounces@linux.kernel.org>
To: Jeff Moyer <jmoyer@redhat.com>
In-Reply-To: <17008.3537.313570.647302@segfault.boston.redhat.com>
List-Unsubscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://hera.kernel.org/pipermail/autofs>
List-Post: <mailto:autofs@linux.kernel.org>
List-Help: <mailto:autofs-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/autofs>,
	<mailto:autofs-request@linux.kernel.org?subject=subscribe>
Sender: autofs-bounces@linux.kernel.org
Errors-To: autofs-bounces@linux.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, 27 Apr 2005, Jeff Moyer wrote:

> Anyway, is this sort of thing supported?  It seems to work, though I am
> uneasy about the whole setup.

Having said that this should be supported is a bit misleading. Perhaps I 
should have said that we could probably make this special case nested 
mount work.

Nested mounts are not supported in autofs maps other than multi-mount maps.

At least that's the case for Solaris automount and should be the case for 
us as well.

So maybe the discussion in the previous post is academic anyway.

Ian
