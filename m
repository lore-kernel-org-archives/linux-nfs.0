From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: NFS lock reclaiming not working on SLES9 SP2
Date: Fri, 17 Feb 2006 11:08:39 -0800
Message-ID: <OF136BE891.79D84BC6-ON88257118.006848D5-88257118.0068D68C@us.ibm.com>
References: <20060217095618.GB25707@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: asha yr <asha_yr@rediffmail.com>,
	Greg Banks <gnb@melbourne.sgi.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	nfs-admin@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
In-Reply-To: <20060217095618.GB25707@suse.de>
To: Olaf Kirch <okir@suse.de>
Sender: nfs-admin@lists.sourceforge.net
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

Hi Olaf,
This fix will not work for HA-NFS which allows a failover node to send the 
SM_NOTIFY on behalf of the failed node.
The -v option was added for this purpose.
Marc. 

nfs-admin@lists.sourceforge.net wrote on 02/17/2006 01:56:18 AM:

> On Fri, Feb 17, 2006 at 08:37:05PM +1100, Greg Banks wrote:
> > In his trace, the client wasn't sending any LOCK calls at all
> > for multiple minutes after receiving the NOTIFY.
> 
> Ah, you're right. I wasn't paying attention to the time stamps.
> 
> It seems the problem is that we're now using hostnames to identify lockd
> peers, but you mounted the file system using the ipaddr:/path.
> 
> Could you please try the attached patch?
> 
> Thanks
> Olaf
> -- 
> Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
> okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
> [attachment "statd-hostname-fix" deleted by Marc Eshel/Almaden/IBM] 


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
