From: Steven Shiau <steven@nchc.org.tw>
Subject: Re: NFS service takes very long time to start when internet disconnected..
Date: Sun, 25 Jul 2004 11:00:01 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040725030001.GA11045@lfod.nchc.org.tw>
References: <20040724063635.GA25341@lfod.nchc.org.tw> <20040724181902.GB18548@suse.de>
Reply-To: steven@nchc.org.tw
Mime-Version: 1.0
Content-Type: text/plain; charset=big5
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BoZFC-00022X-5M
	for nfs@lists.sourceforge.net; Sat, 24 Jul 2004 20:00:10 -0700
Received: from lfod.nchc.org.tw ([140.110.17.130])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BoZFB-0000PM-73
	for nfs@lists.sourceforge.net; Sat, 24 Jul 2004 20:00:10 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040724181902.GB18548@suse.de>
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

Hi,
I do put the IP address in /etc/exports, it looks like:
/tftpboot/node_root 192.168.101.1(ro,sync,async,no_root_squash)
/tftpboot/nodes/192.168.101.1/
192.168.101.1(rw,sync,async,no_root_squash)
/usr 192.168.101.1(ro,sync,async,no_root_squash)
/opt 192.168.101.1(ro,sync,async,no_root_squash)
/home 192.168.101.1(rw,sync,async,no_root_squash)

and the hosts in /etc/nsswitch.conf is:
hosts:      files nisplus nis dns

So... It's very strange... I tried to debug the /etc/init.d/nfs by
appending -x to #/bin/sh, it seems like the boot is stopping here:
action $"Starting NFS services: " /usr/sbin/exportfs -r
where in Fedora Core 1, the action actually runs
initlog /usr/sbin/exportfs -r
So is it the problem of initlog when my eth0 disconnects ?
If so, why ? How can I solve it ?

Thanks in advance.

On Sat, Jul 24, 2004 at 08:19:02PM +0200, Olaf Kirch wrote:
> On Sat, Jul 24, 2004 at 02:36:35PM +0800, Steven Shiau wrote:
> > eth0 can NOT connect to Internet, either it's caused when I move the machine to
> > different subnet while forgetting change the network setting,  or the network cable is disconnected, the Fedore Core 1 takes very long time to boot. It just stops in "Starting NFS service..." for more than 17 minutes...
> > So usually I reboot the machine, and enter the interactive mode to disable the NFS service when it boot.
> > My point is, is that possible I can make the NFS service startup very
> > quickly as usual when the eth0 Internet connection is NOT available ?
> 
> Most liekly you're using host names in your /etc/exports file and
> the resolver tries to map these to addresses. Maybe even wildcarded
> names, I'm not sure if it would try to resolve those too.
> 
> In any case, you can either convert your exports file to use
> IP addresses only, or add all host names to /etc/hosts and make
> sure nsswitch.conf lists the files target before dns.
> 
> Olaf
> 
> -- 
> Olaf Kirch     |  The Hardware Gods hate me.
> okir@suse.de   |
> ---------------+ 

-- 
Please AVOID distributing documents in WORD, EXCEL or POWERPOINT format.
[Chinese Big5] 請避免散佈WORD, EXCEL 或是 POWERPOINT格式的檔案.
See http://www.fsf.org/philosophy/no-word-attachments.html
and http://www.cyut.edu.tw/~ckhung/published/997nodoc.shtml
----------------------------------
Steven Shiau
E-mail: steven _at_ nchc.org.tw; steven _at_ stick.idv.tw


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
