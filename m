From: "H. J. Lu" <hjl@lucon.org>
Subject: Re: nfsroot via NetApp F840
Date: Fri, 20 Sep 2002 14:44:50 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020920144450.A1637@lucon.org>
References: <02092015093803.22012@mavericks>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc52.attbi.com ([216.148.227.88])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17sVZn-0007Xi-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Sep 2002 14:44:39 -0700
To: "Daniel G. Pruitt" <pruitt@lanl.gov>
In-Reply-To: <02092015093803.22012@mavericks>; from pruitt@lanl.gov on Fri, Sep 20, 2002 at 03:09:38PM -0600
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

On Fri, Sep 20, 2002 at 03:09:38PM -0600, Daniel G. Pruitt wrote:
> Hi,
> 
> I'm having difficulties getting nfsroot to mount "/" via a NetApp 
> filer.  Are there any tricks to this, patches I need, etc.?
> 

I don't think you can since device files are special. You may get away
with it using devfs.


H.J.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
