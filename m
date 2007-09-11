From: "Kevin Coffman" <kwc@citi.umich.edu>
Subject: Re: [PATCH 2/3] Remove old logging implementation for idmapd and
	rework gssd and idmapd to use the new xlog logging infrastructure.
Date: Tue, 11 Sep 2007 11:00:27 -0400
Message-ID: <4d569c330709110800g558b1fect5f84ea20e25efc7b@mail.gmail.com>
References: <1189459543.7914.16.camel@moss-terrapins.epoch.ncsc.mil>
	<1189515746.12340.4.camel@moss-terrapins.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1189515746.12340.4.camel@moss-terrapins.epoch.ncsc.mil>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

On 9/11/07, David P. Quigley <dpquigl@tycho.nsa.gov> wrote:
> This patch removes all of the old idmap_* logging functions and replaced them
> with the corresponding xlog functions. In addition that that it also reworks
> the gssd logging wrappers to use the new xlog_backend. Finally it makes
> necessary changes to the build files to get the project compiling again.
>
> Signed-off-by: David P. Quigley <dpquigl@tycho.nsa.gov>
> ---
>
>  static int verbosity = 0;
>  static int fg = 0;
>
> -static char message_buf[500];
> -
>  void initerr(char *progname, int set_verbosity, int set_fg)
>  {
>         verbosity = set_verbosity;
>         fg = set_fg;
>         if (!fg)
> -               openlog(progname, LOG_PID, LOG_DAEMON);
> +               xlog_open(progname);
>  }
>
>
>  void printerr(int priority, char *format, ...)
>  {
>         va_list args;
> -       int ret;
> -       int buf_used, buf_available;
> -       char *buf;
>
>         /* Don't bother formatting a message we're never going to print! */
>         if (priority > verbosity)
>                 return;
>
> -       buf_used = strlen(message_buf);
> -       /* subtract 4 to leave room for "...\n" if necessary */
> -       buf_available = sizeof(message_buf) - buf_used - 4;
> -       buf = message_buf + buf_used;
> -
> -       /*
> -        * Aggregate lines: only print buffer when we get to the
> -        * end of a line or run out of space
> -        */
>         va_start(args, format);
> -       ret = vsnprintf(buf, buf_available, format, args);
> +       if (fg)
> +               vfprintf(stderr, format, args);
> +       else
> +               xlog_backend(L_ERROR, format, args);
>         va_end(args);
> -
> -       if (ret < 0)
> -               goto printit;
> -       if (ret >= buf_available) {
> -               /* Indicate we're truncating */
> -               strcat(message_buf, "...\n");
> -               goto printit;
> -       }
> -       if (message_buf[strlen(message_buf) - 1] == '\n')
> -               goto printit;
> -       return;
> -printit:
> -       if (fg) {
> -               fprintf(stderr, "%s", message_buf);
> -       } else {
> -               syslog(LOG_ERR, "%s", message_buf);
> -       }
> -       /* reset the buffer */
> -       memset(message_buf, 0, sizeof(message_buf));
>  }

Hi David,
I think we need to keep the code in printerr that aggregates lines, or
figure out another way to print the debugging.  The last 20 or so
lines of the following output of svcgssd during a mount when run with
-vvv should be on one line as an ascii dump:

Sep 11 10:50:17 rock rpc.svcgssd[19135]: leaving poll
Sep 11 10:50:17 rock rpc.svcgssd[19135]: handling null request
Sep 11 10:50:17 rock rpc.svcgssd[19135]: in_handle:
Sep 11 10:50:17 rock rpc.svcgssd[19135]: length 0
Sep 11 10:50:17 rock rpc.svcgssd[19135]:
Sep 11 10:50:17 rock rpc.svcgssd[19135]: in_tok:
Sep 11 10:50:17 rock rpc.svcgssd[19135]: length 509
Sep 11 10:50:17 rock rpc.svcgssd[19135]:
Sep 11 10:50:17 rock rpc.svcgssd[19135]:   0000:
Sep 11 10:50:17 rock rpc.svcgssd[19135]: 60
Sep 11 10:50:17 rock rpc.svcgssd[19135]: 82
Sep 11 10:50:17 rock rpc.svcgssd[19135]: 01
Sep 11 10:50:17 rock rpc.svcgssd[19135]: f9
Sep 11 10:50:17 rock rpc.svcgssd[19135]: 06
Sep 11 10:50:17 rock rpc.svcgssd[19135]: 09
Sep 11 10:50:17 rock rpc.svcgssd[19135]: 2a
Sep 11 10:50:17 rock rpc.svcgssd[19135]: 86
Sep 11 10:50:17 rock rpc.svcgssd[19135]: 48
Sep 11 10:50:17 rock rpc.svcgssd[19135]: 86
Sep 11 10:50:17 rock rpc.svcgssd[19135]: f7
Sep 11 10:50:17 rock rpc.svcgssd[19135]: 12
Sep 11 10:50:17 rock rpc.svcgssd[19135]: 01
Sep 11 10:50:17 rock rpc.svcgssd[19135]: 02
Sep 11 10:50:17 rock rpc.svcgssd[19135]: 02
Sep 11 10:50:17 rock rpc.svcgssd[19135]: 01
Sep 11 10:50:17 rock rpc.svcgssd[19135]:
Sep 11 10:50:17 rock rpc.svcgssd[19135]: `
Sep 11 10:50:17 rock rpc.svcgssd[19135]: .
