From: Brian Tinsley <btinsley@emageon.com>
Subject: Re: NFS on linux (Redhat) questions
Date: Fri, 09 Aug 2002 13:15:35 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D5406C7.1040001@emageon.com>
References: <5.1.0.14.2.20020809132700.01b34798@pop.graphics.cornell.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [63.162.183.250] (helo=emgw2ksrv001.emgdom001.emageon.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17dEIX-0008W6-00
	for <nfs@lists.sourceforge.net>; Fri, 09 Aug 2002 11:15:41 -0700
To: Hurf Sheldon <linux@graphics.cornell.edu>
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

1. Upgrade the kernel to 2.4.18-5
2. Upgrade to the latest Intel e1000 drivers (4.3.x) and tune the 
adapter settings in /etc/modules.conf
3. If possible, look into trunking your network connections with Intel 
iANS (some people have a problem with this, it works very well for us)
4. Try using larger rsize and wsize values on the client (8192 is good, 
I've even had success with 32768 - depends on the nature of your beast)
5. Tune network settings in /etc/sysctl.conf (rmem_xxx, wmem_xxx, etc...)
6. Evaluate your choice of underlying filesystem

We use Red Hat 7.3 with NFS on productions systems with PRO/1000 NICs 
(T, F, XT, MT, and MF) and I've never encountered the problems recently 
posted to the mailing list (although there do seem to be some known 
"rare" bugs).


Hurf Sheldon wrote:

> Hi Folks,
> We have a few 4cpu Xeon 550 servers we wanted to make
> central file servers, each with .5tb of ide->scsi raid on them.
> We currently run FreeBSD on our servers; for several reasons,
> Rh7.3 looked like a good replacement.
> Using the standard iso's for Rh 7.3
> Rh 7.3 installed nicely, picking up the Intel 1000 gb interface,
> the 4 cpu's  the ncr and  adaptec scsi interfaces, etc.
>
> Mounting our existing servers on the Rh7.3  (2.4.18-3smp kernel)
> from various FreeBSD systems resulted in timeouts and
> poor performance. Making the Rh7.3 system the server, mounts to
> other Rh7.3 systems and to the FreeBSD systems were not workable.
> Setting rsize, wsize to 1024 made the connections workable but
> trying to set up Rh7.3 nfs install server, where the parameters on the
> boot client can't be set didn't work.
> So, in quick summary:
> Default NFS from FreeBSD systems to the Rh7.3 requires rsize,wsize=1024,
> NFS betwixt Rh7.3 systems also required this to work.
>
> We found your resource pages, subscribed to the newsgroup
> and read the archives. What we found was disconcerting - it appears that
> NFS under Linux is problematic at best.
>
> We would like to use Rh7.3 for our server platforms but we need some 
> guidance
> re: setting up a reliable production machine that we didn't find in 
> the resources - how
> best to get & keep current the pertinent code, build & replace 
> kernels, etc.
>
> What do IBM, HP & Dell do for their Linux server line? Do we want to 
> get Rh
> Enterprise or some other Linux flavor? (reminds me of the "All Unix 
> systems are
> alike, only different" from a decade ago) Or should we stick with the 
> FreeBSD
> for NFS reliability?
>
> We are digesting so if you care to respond directly, please do.
>
> kind regards,
>
> hurf
> Hurf Sheldon
> Program of Computer Graphics     
> 580 Rhodes Hall, Hoy Rd.
> Cornell University 
> Ithaca, N.Y. 14853 
>
> voice:607 255 6713 fax:607 255 0806
> email: hurf@graphics.cornell.edu
> http://www.graphics.cornell.edu/~hurf/ 
> <http://www.graphics.cornell.edu/%7Ehurf/>
>
>
>

-- 
Brian Tinsley
Chief Systems Engineer
Emageon





-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
