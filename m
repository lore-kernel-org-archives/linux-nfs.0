From: Andrew Ryan <andrewr@nam-shub.com>
Subject: Re: 2.4.20-rc1 NFS/TCP client (still) hangs running dbench 2.0
Date: Fri, 1 Nov 2002 14:18:08 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <0211011318080N.01583@stinkpad060501>
References: <3DC2E7B6.6090400@collab.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from laswell.sfo.collab.net ([64.125.134.138])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187jBG-0003ss-00
	for <nfs@lists.sourceforge.net>; Fri, 01 Nov 2002 13:18:14 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <3DC2E7B6.6090400@collab.net>
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

On Friday 01 November 2002 12:44 pm, you wrote:
> " " == Andrew Ryan <andrewr@nam-shub.com> writes:
>       > 2.4.20rc1 still exhibits the same identical problem as
>       > 2.4.19+kmap1 patch which I identified a few weeks ago. I guess
>       > that patch was applied to 2.4.20, since it doesn't appear on
>       > Trond's patch page for 2.4.20.
>
> Does the following patch work for you?

So far so good on the crashes.  I'm able to get through a complete run of 
dbench using TCP mounts on 2.4.20rc1, which I haven't been able to do before 
this. 

However, according to nfsstat -c's "Client rpc stats", I'm getting around a 
10:1 ratio of retransmits to calls. That's bad. I get 0 retransmits when 
using 2.4.19+kmap1, and any previous kernel I've ever tried TCP mounting 
with. I checked 2.4.20rc1-vanilla and it does the same thing, so it's not the 
latest patch.



andrewr


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
