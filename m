From: Spencer Shepler <shepler@eng.sun.com>
Subject: Re: NFSv3 and v2
Date: Tue, 3 Sep 2002 20:55:42 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020904015542.GY100366@dhcp-uaus08-128-212.sun.com>
References: <3D755A43.2020501@linkvest.com>
Reply-To: spencer.shepler@sun.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS <NFS@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
To: Jean-Eric Cuendet <jean-eric.cuendet@linkvest.com>
In-Reply-To: <3D755A43.2020501@linkvest.com>
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

On Wed, Jean-Eric Cuendet wrote:
> Hi,
> Is it enough if my NFS server implements only the NFSv3 interface from 
> nfs3_prot.x or is it NECESSARY to implement the nfs_prot.x also.
> I plan to have only NFSv3 clients.
> 

There is no requirement to implement NFS version 2.  An NFSv3 server
is viable.  Don't forget about the file locking RPC program NLM if you
want your server to provide file locking services to its clients as
well.

Spencer


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
