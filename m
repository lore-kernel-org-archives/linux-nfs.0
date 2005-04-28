From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: nested mounts -- supported?
Date: Thu, 28 Apr 2005 10:13:35 -0400
Message-ID: <17008.61327.523076.917471@segfault.boston.redhat.com>
References: <17008.3537.313570.647302@segfault.boston.redhat.com>
	<Pine.LNX.4.58.0504281639350.14881@wombat.indigo.net.au>
Reply-To: jmoyer@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: autofs mailing list <autofs@linux.kernel.org>, nfs@lists.sourceforge.net
Return-path: <autofs-bounces@linux.kernel.org>
To: Ian Kent <raven@themaw.net>
In-Reply-To: <Pine.LNX.4.58.0504281639350.14881@wombat.indigo.net.au>
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

==> Regarding Re: nested mounts -- supported?; Ian Kent <raven@themaw.net> adds:

raven> On Wed, 27 Apr 2005, Jeff Moyer wrote:
>> Anyway, is this sort of thing supported?  It seems to work, though I am
>> uneasy about the whole setup.

raven> Having said that this should be supported is a bit
raven> misleading. Perhaps I should have said that we could probably make
raven> this special case nested mount work.

raven> Nested mounts are not supported in autofs maps other than
raven> multi-mount maps.

raven> At least that's the case for Solaris automount and should be the
raven> case for us as well.

raven> So maybe the discussion in the previous post is academic anyway.

I think this is a perfectly acceptable answer (and indeed what I was
looking for).

Thanks,

Jeff
