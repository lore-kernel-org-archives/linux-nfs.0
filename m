From: David Rees <dbr@greenhydrant.com>
Subject: Re: NFS read ok, write ok, simultaneous R+W=TERRIBLE
Date: Thu, 5 Dec 2002 11:55:00 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20021205115500.A9837@greenhydrant.com>
References: <200212051728.gB5HS1jH005843@pookie.nersc.gov> <CFEAJJEGMGECBCJFLGDBGEIHCJAA.hammer@clarkisland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [208.48.139.185] (helo=forty.greenhydrant.com)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18K25S-0005mB-00
	for <nfs@lists.sourceforge.net>; Thu, 05 Dec 2002 11:55:06 -0800
To: NFS <nfs@lists.sourceforge.net>
In-Reply-To: <CFEAJJEGMGECBCJFLGDBGEIHCJAA.hammer@clarkisland.com>; from hammer@clarkisland.com on Thu, Dec 05, 2002 at 10:35:14AM -0800
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

On Thu, Dec 05, 2002 at 10:35:14AM -0800, Jake Hammer wrote:
> 
> > Also, are the NFSd's in disk wait?
> 
> Could you tell me how to check this? I'll be pleased to report once I know
> how.
> 
> > If they are not, then
> > this would be a clearer indications that the nfs subsystem
> > may be to blame.  We usually see all the daemons in
> > disk wait when we are really pounding one of the these
> > boxes.
> 
> Yes, I'd love to be able to check. Please let me know how. This sounds
> interesting.

I doubt that the NFSd's are in disk wait given that you mentioned that 4
of them are sucking up CPU as indicated in your original post:
http://marc.theaimsgroup.com/?l=linux-nfs&m=103905720718370&w=2

However, to check if a process is indeed in disk wait, running top will
show you.  Under the stat column, instead of a R, you will see D
indicating a process waiting on a disk command to return.

Sounds like a legitimate problem with the NFS server code, I'll also see
if I can reproduce.

-Dave


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
