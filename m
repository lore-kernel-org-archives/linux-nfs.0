From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: can't get request slot, write timeout
Date: Tue, 13 Aug 2002 12:52:49 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0208131229500.15089-100000@kenzo.iwr.uni-heidelberg.de>
References: <shsadnroqw7.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eZIF-0001T5-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 03:52:55 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsadnroqw7.fsf@charged.uio.no>
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

On 12 Aug 2002, Trond Myklebust wrote:

> I wasn't aware that you'd seen better behaviour with the last set of
> patches. Feedback is always welcome - particularly now when I'm trying
> to work out exactly what we should aim to get into kernel 2.4.20! 

I actually haven't reached a conclusion yet as a result of lack of time.  
My plan was to test it in a controlled "bad" environment, with big speed
(CPU and disk) difference between client and server (and changing roles
afterwards) and with simulated network problems (duplex mismatch, ping
flood, forced Tx timeout). I _think_ that I've already seen an 
improvement, but testing was interrupted by other duties and I'll probably 
have to restart it as I don't have the same hardware anymore :-(

> The only TCP trick we cannot implement is that of sending messages of
> length > 1.5k without using fragmentation. That again means that if 1
> fragment is lost, we have to resend 32k (or 8k or whatever the r/wsize
> is set to) rather than only the 1.5k that was actually missing...

Would it be possible that if the client detects too many fragments to be 
retransmitted _and_ the fragment size is high (like 32k) to scale back and 
only send smaller fragments ? Would that break any NFS rule ?
And I don't know how the actual size would be communicated back to 
user-space...

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
