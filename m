From: raven@themaw.net
Subject: Re: NFS readonly failover and linux?
Date: Sat, 29 Jan 2005 11:46:52 +0800 (WST)
Message-ID: <Pine.LNX.4.61.0501291127450.1607@donald.themaw.net>
References: <1106871309.6181.254.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CujkX-0004rP-CJ
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 19:58:17 -0800
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CujkW-0002kz-Iv
	for nfs@lists.sourceforge.net; Fri, 28 Jan 2005 19:58:17 -0800
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1106871309.6181.254.camel@seki.nac.uci.edu>
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

On Thu, 27 Jan 2005, Dan Stromberg wrote:

>
> The autofs man pages on Redhat Enterprise Linux 3 as well as Fedora Core
> 3 both say that autofs supports replicated, readonly fileserver failover
> - but then there's a footnote of sorts that says autofs only supports it
> to the extent that mount does.

That part of the man page is old and slightly out of date.

The reason that this is left there is that autofs cannot support 
dynamic failover as it just uses mount. However, a different host may be 
selected at mount, after a previous timeout, for example. The issue of 
umounting existing mounts from servers that have gone away is not 
explicitly dealt with yet.

>
> Upon trying to do such a mount, I get:
>
> seki-root> mount
> dcslib1.nacs.uci.edu,dcslib4.nacs.uci.edu:/dcspdb/rhel-3-i686 /mnt/nfs
> mount: warning: multiple hostnames not supported
> Thu Jan 27 16:12:18

What version of autofs are you using?
The autofs replicated server code is still relatively new.

If your autofs supports replicated server map entries then multiple 
host mount requests will not reach the mount command.

If you are using a RedHat based distro then check
http://people.redhat.com/jmoyer
for the latest patched versions

Also, you may need a kernel patch depending on your kernel version. See 
README.patches in the distribution or join the autofs list at
http://linux.kernel.org/mailman/listinfo/autofs

>
> seki-root>
>
>
> Is there a version of mount available, or in early development, that
> supports this feature?

Don't know. Anyone?

Ian


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
