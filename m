From: Olaf Kirch <okir@suse.de>
Subject: Re: NFS service takes very long time to start when internet disconnected..
Date: Sat, 24 Jul 2004 20:19:02 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040724181902.GB18548@suse.de>
References: <20040724063635.GA25341@lfod.nchc.org.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BoR8Y-0004xn-Bc
	for nfs@lists.sourceforge.net; Sat, 24 Jul 2004 11:20:46 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BoR8X-0000YX-Rx
	for nfs@lists.sourceforge.net; Sat, 24 Jul 2004 11:20:46 -0700
To: Steven Shiau <steven@nchc.org.tw>
In-Reply-To: <20040724063635.GA25341@lfod.nchc.org.tw>
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

On Sat, Jul 24, 2004 at 02:36:35PM +0800, Steven Shiau wrote:
> eth0 can NOT connect to Internet, either it's caused when I move the machine to
> different subnet while forgetting change the network setting,  or the network cable is disconnected, the Fedore Core 1 takes very long time to boot. It just stops in "Starting NFS service..." for more than 17 minutes...
> So usually I reboot the machine, and enter the interactive mode to disable the NFS service when it boot.
> My point is, is that possible I can make the NFS service startup very
> quickly as usual when the eth0 Internet connection is NOT available ?

Most liekly you're using host names in your /etc/exports file and
the resolver tries to map these to addresses. Maybe even wildcarded
names, I'm not sure if it would try to resolve those too.

In any case, you can either convert your exports file to use
IP addresses only, or add all host names to /etc/hosts and make
sure nsswitch.conf lists the files target before dns.

Olaf

-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
