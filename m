From: Olaf Kirch <okir@suse.de>
Subject: Re: NFS service takes very long time to start when internet disconnected..
Date: Sun, 25 Jul 2004 14:23:45 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040725122345.GB8512@suse.de>
References: <20040724063635.GA25341@lfod.nchc.org.tw> <20040724181902.GB18548@suse.de> <20040725030001.GA11045@lfod.nchc.org.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Boi2g-0007Gk-Aa
	for nfs@lists.sourceforge.net; Sun, 25 Jul 2004 05:23:50 -0700
Received: from cantor.suse.de ([195.135.220.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1Boi2f-0008VV-TC
	for nfs@lists.sourceforge.net; Sun, 25 Jul 2004 05:23:50 -0700
To: Steven Shiau <steven@nchc.org.tw>
In-Reply-To: <20040725030001.GA11045@lfod.nchc.org.tw>
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

On Sun, Jul 25, 2004 at 11:00:01AM +0800, Steven Shiau wrote:
> So is it the problem of initlog when my eth0 disconnects ?
> If so, why ? How can I solve it ?

Did you try putting these addresses into /etc/hosts along with some
names? Could be that using addresses is not enough,and exportfs is
doing a reverse lookup by default.

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
