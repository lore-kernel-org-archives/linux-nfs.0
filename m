Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42223 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751253Ab3HSMFw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Aug 2013 08:05:52 -0400
Date: Mon, 19 Aug 2013 08:06:44 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jan Stancek <jstancek@redhat.com>, linux-nfs@vger.kernel.org,
        bfields@redhat.com, Trond Myklebust <Trond.Myklebust@netapp.com>,
        idra@samba.org
Subject: Re: [PATCH] NFS: fix NFSv3 with sec=krb5 and CONFIG_NFS_V3_ACL=y
Message-ID: <20130819080644.0a6cae56@corrin.poochiereds.net>
In-Reply-To: <20130816191634.GA19942@fieldses.org>
References: <682ebd8ecc7309b18396da356a0feb38bfa41674.1372692346.git.jstancek@redhat.com>
	<20130708201643.GI29071@fieldses.org>
	<1157529877.873319.1373353194344.JavaMail.root@redhat.com>
	<20130726220924.GG30651@fieldses.org>
	<20130815100244.370de645@corrin.poochiereds.net>
	<20130815141917.GR17781@fieldses.org>
	<20130816150454.2aacd5ff@corrin.poochiereds.net>
	<20130816191634.GA19942@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 16 Aug 2013 15:16:34 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Aug 16, 2013 at 03:04:54PM -0400, Jeff Layton wrote:
> > On Thu, 15 Aug 2013 10:19:18 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Thu, Aug 15, 2013 at 10:02:44AM -0400, Jeff Layton wrote:
> > > > On Fri, 26 Jul 2013 18:09:24 -0400
> > > > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > > 
> > > > > On Tue, Jul 09, 2013 at 02:59:54AM -0400, Jan Stancek wrote:
> > > > > > 
> > > > > > 
> > > > > > 
> > > > > > 
> > > > > > ----- Original Message -----
> > > > > > > From: "J. Bruce Fields" <bfields@fieldses.org>
> > > > > > > To: "Jan Stancek" <jstancek@redhat.com>
> > > > > > > Cc: linux-nfs@vger.kernel.org, bfields@redhat.com, "Trond Myklebust" <Trond.Myklebust@netapp.com>
> > > > > > > Sent: Monday, 8 July, 2013 10:16:43 PM
> > > > > > > Subject: Re: [PATCH] NFS: fix NFSv3 with sec=krb5 and CONFIG_NFS_V3_ACL=y
> > > > > > > 
> > > > > > > On Mon, Jul 01, 2013 at 05:32:34PM +0200, Jan Stancek wrote:
> > > > > > > > Starting with commit:
> > > > > > > >   commit f994c43d19a9116727d4c228d3f13db595bff562
> > > > > > > >   Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > > > > > >   Date:   Thu Nov 1 12:14:14 2012 -0400
> > > > > > > >       SUNRPC: Clean up rpc_bind_new_program
> > > > > > > > 
> > > > > > > > operations on directory mounted with -onfsvers=3,tcp,sec=krb5 fail
> > > > > > > > with Input/Output error after ~60 second timeout. This is presumably
> > > > > > > > because upcalls for 'nfsacl' are not getting anywhere.
> > > > > > > > 
> > > > > > > > This patch enables pipe dir for nfsacl_program and changes its name
> > > > > > > > to 'nfs'. This name will be used in upcalls and whole setup should
> > > > > > > > work as it did in past - just with nfs/hostname principal.
> > > > > > > 
> > > > > > > I think this was the problem that nfs-utils commits
> > > > > > > 
> > > > > > > 	a1f8afc560 gssd: Remove insane sanity checks of the service name
> > > > > > > 	a56989b665 gssd: Handle the target name correctly
> > > > > > > 
> > > > > > > were supposed to fix?
> > > > > > > 
> > > > > > > But perhaps the kernel needs a fix too to fix a regression with old
> > > > > > > userspace.
> > > > > > 
> > > > > > I saw this error with nfs-utils.1.2.9-rc1, which should already contain
> > > > > > those 2 commits.
> > > > > 
> > > > > Actually, I think your patch is just a subset of Trond's
> > > > > http://mid.gmane.org/<4FA345DA4F4AE44899BD2B03EEEC2FA9092EC392@SACEXCMBX04-PRD.hq.netapp.com>
> > > > > 
> > > > > Trond, is there a reason that never got applied?
> > > > > 
> > > > > --b.
> > > > > 
> > > > 
> > > > Hmm...gmane just says "No such article" when I feed it the above URL.
> > > > Do you know what the title of the email was?
> > > 
> > > Argh sorry hadn't noticed that was private mail.
> > > 
> > > Last I checked actually neither of these patches fixed v3/krb5 for me.
> > > 
> > > --b.
> > > 
> > > Here is v2 with appropriate service names for mountd, statd, etc.
> > > 
> > > 
> > 
> > Ok, I tested both this patch and Jan's. This one doesn't help at all,
> > but Jan's does seem to fix the problem. I'm still looking over the
> > kernel and userland code to determine whether it's the best fix or
> > not...
> 
> Ah, crap, sorry, I missed that Jan's modified rpc_program.name and
> Trond's rpc_program.service_name.
> 
> As Simo pointed out in irc yesterday this can't be right:
> 
> > > diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> > > index 909dc0c..b19dab8 100644
> > > --- a/net/sunrpc/auth_gss/auth_gss.c
> > > +++ b/net/sunrpc/auth_gss/auth_gss.c
> > > @@ -403,7 +403,9 @@ static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
> > >  				   gss_msg->uid);
> > >  	p += gss_msg->msg.len;
> > >  	if (clnt->cl_principal) {
> > > -		len = sprintf(p, "target=%s ", clnt->cl_principal);
> > > +		len = sprintf(p, "target=%s@%s ",
> > > +				clnt->cl_program->service_name,
> > > +				clnt->cl_principal);
> 
> I'd think this should instead be going in the "service_name" field, but
> I'm not sure.
> 


Actually, this patch seems to work correctly. The only thing that was
missing was the pipe_dir_name field for the nfsacl program. There is a
separate service= field that gssd understands as well, but I don't see
any read advantage to using that over this patch. I'll send a respun
patch in a bit that seems to fix this for me.

I'll also note that several other rpc_programs don't have their
pipe_dir_name set. We may want to go ahead and set those as well in
case we ever do want to enable GSSAPI auth for those services.

-- 
Jeff Layton <jlayton@redhat.com>
