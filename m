From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] sanitize logging subsystem
Date: Mon, 14 Mar 2005 16:51:06 +1100
Message-ID: <16949.9802.377554.583900@cse.unsw.edu.au>
References: <200503111518.29792.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAiU3-000282-SZ
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 21:51:19 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DAiU2-00077O-7b
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 21:51:19 -0800
To: Denis Vlasenko <vda@ilport.com.ua>
In-Reply-To: message from Denis Vlasenko on Friday March 11
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Friday March 11, vda@ilport.com.ua wrote:
> It seems like there are several ways to log messages or
> display them on std{out,err} in nfs utils, more or less
> similar to each other. Let's try to untangle them.
> 
> I'll start from cleaning up xlog.c:
> 
> * There is no external API to log to arbitrary FILE*,
>   we can drop code which supports this internally.
>   Patch converts xlog.c to directly use stderr.
> * Print date/time in ISO (YYYY-MM-DD HH:MM:SS) format.
> * Add support for disabling logging to syslog.
> 
> Patch does not introduce behavioral changes except for
> making foregrounded mountd to really use stderr.
> There was a bug which prevented this.
> 
> Patch is tested. Please comment/apply.

How well was it tested :-)

> +		fprintf(stderr, "%s[%d] %04d-%02d-%02d %02d:%02d:%02d %s\n",
> +				log_name, log_pid,
> +				tm->tm_year, tm->tm_mon + 1, tm->tm_mday,
> +				tm->tm_hour, tm->tm_min, tm->tm_sec,
> +				buff);

tm_year is "number of years since 1900", which isn't what you want to
print out.  It needs a "+1900", which I have given it.

Otherwise the patch looks reasonably sane.
The only bit that bothers me is calling openlog in mountd where it
wasn't called before.
mountd (on debian at least) currently prefixes all log lines with
"rpc_mountd" as that is the program name.  With this patch they will
be prefixes with "mountd".
This is a change and people who filter their log file (like me) might
notice.   But it probably isn't a big concern..

I've committed it to CVS.

Thanks,
NeilBrown


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
