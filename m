From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: padding the fh
Date: Tue, 3 Sep 2002 12:32:16 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15732.7984.712458.77138@notabene.cse.unsw.edu.au>
References: <003101c250b7$8ad7a220$4f0010ac@Ashwamedha>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17m3US-0007Yk-00
	for <nfs@lists.sourceforge.net>; Mon, 02 Sep 2002 19:32:28 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.85] == wireless-085.wireless.cse.unsw.EDU.AU)
	(for <kedar@calsoftinc.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 3 Sep 2002 12:32:16 +1000
To: "Kedar Sovani" <kedar@calsoftinc.com>
In-Reply-To: message from Kedar Sovani on Saturday August 31
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

On Saturday August 31, kedar@calsoftinc.com wrote:
> hi, 
>        I have a problem. Does the linux nfs client follow the rule that the file handle it recieves is opaque to it(the client).?
>         The problem that i have is, i am sitting at the server, and
trying to pad the file handle being sent back by the exp_rootfh
function in linux kernel 2.4.18-3. When i do sich a thing, i recevie
one more MOUNt request by the client,but this is a MOUNTv2
request. Later, the client sends the GETATTR, FSTAT & FSINFO
commands(this is sent using the NFsv3 protocol), and sooon later, it
sends the same commands with NFSv2.  
>         Can anyone explain this behavior to me. Why might this be
happening. I want to use a padded version of the file handle for the
rest of the server activities. How do i go abt it ? 
> 


Maybe if you tried explaining why you want to pad the filehandle... I
cannot see any reason to pad it, so I cannot picture what you are
actually doing, so I cannot answer why it doesn't work.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
