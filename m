From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: Problems with statd and lockd
Date: Sat, 5 Apr 2003 18:31:09 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200304051831.09682.bernd-schubert@web.de>
References: <20030405015638.5118fbb9.philippe.gramoulle@mmania.com> <200304051545.43063.bernd-schubert@web.de> <shs7ka9c957.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from smtp02.web.de ([217.72.192.151] helo=smtp.web.de)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 191qZF-0008SJ-00
	for <nfs@lists.sourceforge.net>; Sat, 05 Apr 2003 08:30:57 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shs7ka9c957.fsf@charged.uio.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Saturday 05 April 2003 16:27, Trond Myklebust wrote:
> >>>>> " " == Bernd Schubert <bernd-schubert@web.de> writes:
>      > we also see those messages when we use the rpc.statd from
>      > debian packages. I think the debian nfs-utils packages got
>      > "--enable-secure-statd" as configure option. After recompiling
>      > the nfs-utils without this option and starting the new
>      > rpc.statd on the clients, those messages should disappear, even
>      > without restarting the nfs-server.  (I discovered this odd
>      > behaviour by accident.)
>
> --enable-secure-statd is there for a good reason. I wouldn't recommend
> that anybody turn it off. In any case, if that is the problem, then
> you should see a warning from 'statd' in your syslog (assuming you
> have enabled 'warn' messages in syslog.conf).
>
> Cheers,
>   Trond
>

Hello,

here are the entries from our /etc/syslog.conf about warnings:

*.=info;*.=notice;*.=warn;\
        auth,authpriv.none;\
        cron,daemon.none;\
        mail,news.none          -/var/log/messages

So I think warnings are enabled. Recently the self-created nfs-utils packages 
(with disabled --enable-secure-statd) got replaced by an automatic update. 
Some time afterwards our clients began to give those messages (here as 
dmesg-output):

statd: server localhost not responding, timed out
nsm_mon_unmon: rpc failed, status=-5
lockd: cannot monitor <server IP>
lockd: failed to monitor <server IP>

So on our systems not the server, but the clients are reporting those 
messages. Though I have to admit that our server is also running nfs-utils 
without secure-statd support, but as much as I can remember there where 
similar messages on the server when secure-statd was enabled.

The /var/log/messages has this entries: 

Apr  5 15:28:16 maxwell kernel: statd: server localhost not responding, timed 
out
Apr  5 15:28:16 maxwell kernel: lockd: cannot monitor <server IP>
Apr  5 15:28:16 maxwell kernel: lockd: failed to monitor <server IP>

What other messages do you expect ?

As soon as I stop the debian-statd and start the new statd (that has 
secure-statd disabled), those messages disappear.
Furthermore, some programs as e.g. KDE have some problems to run when those 
messages appear (our home directory is served by this server).

What problems can be caused by a statd without the secure option ? 


Thanks in advance,	
	Bernd


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
