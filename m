From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv4 and client caching to local disk?
Date: Fri, 28 Mar 2003 10:01:26 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030328150125.GA16591@fieldses.org>
References: <3E843E86.9030701@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=mail)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18yvMo-0002jg-00
	for <nfs@lists.sourceforge.net>; Fri, 28 Mar 2003 07:02:02 -0800
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: <3E843E86.9030701@moving-picture.com>
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

On Fri, Mar 28, 2003 at 12:22:30PM +0000, James Pearson wrote:
> I'm trying to find out more about 'cachefs' type file systems that can 
> cache NFS data to a client's local disk - I've come across a couple of 
> references that seem to indicate that this may be possible with NFSv4.
> 
> Does (will?) the Linux NFSv4 client support this feature?

Nobody's working on it now as far as I know.  You might do a search for
'cachefs' on the linux-kernel mailing list:

http://groups.google.com/groups?hl=en&lr=&ie=UTF-8&oe=UTF-8&q=group%3Afa.linux.kernel+cachefs&btnG=Google+Search

I seem to remember some relevant discussions there.--Bruce F.


-------------------------------------------------------
This SF.net email is sponsored by:
The Definitive IT and Networking Event. Be There!
NetWorld+Interop Las Vegas 2003 -- Register today!
http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
