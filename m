From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: Passing sec info to security modules when mounting an FS
Date: Wed, 06 Jun 2007 15:45:21 -0400
Message-ID: <1181159121.3699.214.camel@moss-spartans.epoch.ncsc.mil>
References: <1180739989.3931.47.camel@localhost.localdomain>
	<1180965288.14220.43.camel@moss-spartans.epoch.ncsc.mil>
	<1181157747.3776.18.camel@dhcp231-215.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: trond.myklebust@fys.uio.no, hch@infradead.org,
	nfs@lists.sourceforge.net, viro@zeniv.linux.org.uk,
	selinux@tycho.nsa.gov
To: Eric Paris <eparis@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hw1Rm-0007ob-Oz
	for nfs@lists.sourceforge.net; Wed, 06 Jun 2007 12:45:34 -0700
Received: from zombie.ncsc.mil ([144.51.88.131] helo=jazzdrum.ncsc.mil)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hw1Ro-0001eI-IM
	for nfs@lists.sourceforge.net; Wed, 06 Jun 2007 12:45:38 -0700
In-Reply-To: <1181157747.3776.18.camel@dhcp231-215.rdu.redhat.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2007-06-06 at 15:22 -0400, Eric Paris wrote:
> On Mon, 2007-06-04 at 09:54 -0400, Stephen Smalley wrote:
> > On Fri, 2007-06-01 at 19:19 -0400, Eric Paris wrote:
> 
> > > ?the nfs code - can just store the full text string it got in userspace
> > > and pass it along.  Other binary mount data FS's could do the same
> > > thing.  (I think this is the best option)
> > 
> > I don't think that makes much sense from the filesystem point of view -
> > the filesystem owns the options and parses them, passing only a flag to
> > indicate the type of option (context, fscontext, defcontext) and the
> > option value, not the prefixes, to the security module.
> > 
> > I'd expect it to be a direct call from the nfs option parsing code to a
> > security function (which internally would call the security module's
> > operation); no need to call back into the vfs there.
> 
> So it sounded good, tried to start coding the interface but couldn't
> think how to keep security module specific information out of the FS.
> SELinux in particular can grok 4 mount options, 
> 
> fscontext=
> context=
> rootcontext=
> defcontext=
> 
> NFS at the moment can only grok 1 of those 4 (far and away the most
> common) context= but I want the interface to be generic right?  Lets say
> we were to create a new security function:
> 
> security_set_mount_option(struct *sb, char *option, int flag)
> 
> where the value of flag tells you what the information in *option is
> supposed to be setting. Immediately after the vfs_kern_mount call a FS
> which uses binary mount options could call into this new function thus
> avoiding the bad NFS specific code in the SELinux security module.
> 
> The problem is that the FS needs to now have security module specific
> knowledge in order to know how to pass the flag telling the security
> module what it is trying to set.  We just moved NFS specific knowledge
> outside of the security module and put security module specific
> knowledge into the FS.  What is SELinux isn't the security module?  The
> meaning of 'flags' for SELinux would be which of those 4 above options
> they want to set.  Now NFS has to know if selinux is being used or some
> other unknown security module which needs a different set of flag
> meanings.  Where does this get worked out?  In the text mount data the
> security code does all the parsing, so the FS doesn't need to know what
> the security module does or does not understand, although it seems like
> people don't think that's the right thing even for the text options
> case.
> 
> I'd be perfectly happy coding this with a hard coded value for the flag
> in NFS code and have that set the context=.  Honestly right now it looks
> like nfs is going to be the only user and i certainly don't expect nfs
> to expand the binary data to support the other rarely used SELinux
> options.  But it seems like a problem to me when the FS needs to
> understand all of the options for all of the possible security module
> needs (even if right now SELinux is the only security module I know of
> using this sort of thing....)
> 
> Any comments?

As I understand it, the filesystem owns the options, not the security
module, so the filesystem has to know them all.  So yes, you'd just
define a flag for the context option and use that one for context=.  The
dummy module can then implement the security_set_mount_option() hook by
always returning -EINVAL so that it will reject any attempts to use that
option, and any other security modules can do likewise or can do so
selectively depending on whether they support the flag in question.

Although that hook should likely take an array so that you can pass all
of the security-related options as a single call, as they might need to
be considered together.

-- 
Stephen Smalley
National Security Agency


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
