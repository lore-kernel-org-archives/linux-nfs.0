From: Greg Lindahl <lindahl@keyresearch.com>
Subject: Re: Performance problem
Date: Wed, 15 May 2002 10:42:25 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020515104225.B1754@wumpus.keyresearch.com>
References: <62D26CC4CB1CD3118EAA00805FBB65FA0B8B905E@perm01.woodside.com.au> <1021452381.32242.5.camel@nb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nixon.xkey.com ([209.245.148.124])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1782ms-00016c-00
	for <nfs@lists.sourceforge.net>; Wed, 15 May 2002 10:42:06 -0700
Received: (from lindahl@localhost)
	by localhost.conservativecomputer.com (8.11.6/8.11.0) id g4FHgPh01823
	for nfs@lists.sourceforge.net; Wed, 15 May 2002 10:42:25 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <1021452381.32242.5.camel@nb>; from nb@many.be on Wed, May 15, 2002 at 10:46:20AM +0200
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Wed, May 15, 2002 at 10:46:20AM +0200, Nicolas Brainez wrote:

> - Change the NIC (old was rtl8139, new is AMD pcnet32): no changes

The rtl8139 is a terrible NIC. It doesn't seem to work under high load
under any OS.

> - Pinging server with 8192 bytes: high packet loss ! (between 30 & 90%)

Well, there's your problem. As you could imagine, NFS with 8k packets
won't work so well, but you won't notice for telnet.

You have 2 choices to cover up the problem:

1) Use NFS over TCP.
2) Use NFS with UDP and 1k packets.

As for what the underlying problem is, I don't really know. I would
follow up by using "netperf" or another TCP-related test to see if the
TCP bandwidth is acceptable. If it is, then you can not fix it...

greg

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
