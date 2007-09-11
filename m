From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: Re: [PATCH 2/3] Remove old logging implementation for idmapd
	and	rework gssd and idmapd to use the new xlog logging
	infrastructure.
Date: Tue, 11 Sep 2007 11:06:48 -0400
Message-ID: <1189523208.12340.10.camel@moss-terrapins.epoch.ncsc.mil>
References: <1189459543.7914.16.camel@moss-terrapins.epoch.ncsc.mil>
	<1189515746.12340.4.camel@moss-terrapins.epoch.ncsc.mil>
	<4d569c330709110800g558b1fect5f84ea20e25efc7b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IV7Pc-0002dZ-8v
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 08:12:24 -0700
Received: from zombie.ncsc.mil ([144.51.88.131] helo=jazzdrum.ncsc.mil)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IV7Pf-0003Cf-Iq
	for nfs@lists.sourceforge.net; Tue, 11 Sep 2007 08:12:29 -0700
In-Reply-To: <4d569c330709110800g558b1fect5f84ea20e25efc7b@mail.gmail.com>
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

Could you point me to the second in gssd that is doing this? It might be
better to use the print statements in a saner way.

Dave

On Tue, 2007-09-11 at 11:00 -0400, Kevin Coffman wrote:
> On 9/11/07, David P. Quigley <dpquigl@tycho.nsa.gov> wrote:
> > This patch removes all of the old idmap_* logging functions and replaced them
> > with the corresponding xlog functions. In addition that that it also reworks
> > the gssd logging wrappers to use the new xlog_backend. Finally it makes
> > necessary changes to the build files to get the project compiling again.
> >
> > Signed-off-by: David P. Quigley <dpquigl@tycho.nsa.gov>
> > ---
> >
> >  static int verbosity = 0;
> >  static int fg = 0;
> >
> > -static char message_buf[500];
> > -
> >  void initerr(char *progname, int set_verbosity, int set_fg)
> >  {
> >         verbosity = set_verbosity;
> >         fg = set_fg;
> >         if (!fg)
> > -               openlog(progname, LOG_PID, LOG_DAEMON);
> > +               xlog_open(progname);
> >  }
> >
> >
> >  void printerr(int priority, char *format, ...)
> >  {
> >         va_list args;
> > -       int ret;
> > -       int buf_used, buf_available;
> > -       char *buf;
> >
> >         /* Don't bother formatting a message we're never going to print! */
> >         if (priority > verbosity)
> >                 return;
> >
> > -       buf_used = strlen(message_buf);
> > -       /* subtract 4 to leave room for "...\n" if necessary */
> > -       buf_available = sizeof(message_buf) - buf_used - 4;
> > -       buf = message_buf + buf_used;
> > -
> > -       /*
> > -        * Aggregate lines: only print buffer when we get to the
> > -        * end of a line or run out of space
> > -        */
> >         va_start(args, format);
> > -       ret = vsnprintf(buf, buf_available, format, args);
> > +       if (fg)
> > +               vfprintf(stderr, format, args);
> > +       else
> > +               xlog_backend(L_ERROR, format, args);
> >         va_end(args);
> > -
> > -       if (ret < 0)
> > -               goto printit;
> > -       if (ret >= buf_available) {
> > -               /* Indicate we're truncating */
> > -               strcat(message_buf, "...\n");
> > -               goto printit;
> > -       }
> > -       if (message_buf[strlen(message_buf) - 1] == '\n')
> > -               goto printit;
> > -       return;
> > -printit:
> > -       if (fg) {
> > -               fprintf(stderr, "%s", message_buf);
> > -       } else {
> > -               syslog(LOG_ERR, "%s", message_buf);
> > -       }
> > -       /* reset the buffer */
> > -       memset(message_buf, 0, sizeof(message_buf));
> >  }
> 
> Hi David,
> I think we need to keep the code in printerr that aggregates lines, or
> figure out another way to print the debugging.  The last 20 or so
> lines of the following output of svcgssd during a mount when run with
> -vvv should be on one line as an ascii dump:
> 
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: leaving poll
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: handling null request
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: in_handle:
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: length 0
> Sep 11 10:50:17 rock rpc.svcgssd[19135]:
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: in_tok:
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: length 509
> Sep 11 10:50:17 rock rpc.svcgssd[19135]:
> Sep 11 10:50:17 rock rpc.svcgssd[19135]:   0000:
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: 60
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: 82
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: 01
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: f9
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: 06
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: 09
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: 2a
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: 86
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: 48
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: 86
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: f7
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: 12
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: 01
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: 02
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: 02
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: 01
> Sep 11 10:50:17 rock rpc.svcgssd[19135]:
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: `
> Sep 11 10:50:17 rock rpc.svcgssd[19135]: .


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
