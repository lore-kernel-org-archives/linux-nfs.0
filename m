From: Robert Sander <ml-linux-nfs@epigenomics.com>
Subject: Re: NFS, Berkley mailboxes, locking, and corruption
Date: Tue, 9 Mar 2004 17:17:12 +0000 (UTC)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <news2mail-slrnc4rv0o.7gg.gurubert-dated-1078842485.kblajmfp@moneta.epigenomics.epi>
References: <Pine.LNX.4.44.0401312058440.23263-100000@poplar.sktc.net>
Reply-To: Robert Sander <gurubert-dated-1078842485.kblajmfp@epigenomics.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0l01-00023W-D3
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 09:26:37 -0800
Received: from gk.ka.epigenomics.net ([62.159.77.106] ident=qmailr)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B0kr7-00045i-9M
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 09:17:25 -0800
To: nfs@lists.sourceforge.net
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

On Sun, 1 Feb 2004 03:43:58 +0000 (UTC),
 Justin <listuser@numbnuts.net> wrote:
> Another alternative is maildir.  I know Procmail can be tricked into
> writing it.  I don't believe Qpopper has support for it.  I know UW-IMAP
> doesn't support it.  We have to have IMAP for webmail.  All the users use
> POP with their choice of MUA.  I think MailDir would be more of a problem
> in the long run unfortunately.

Hi!

Maildir is not a problem in the long run. There are plenty pieces of
software being able to write/read to/from a Maildir and speak
SMTP/IMAP/POP3.

Go with Maildir, it's safe over NFS. No need for locking at all.

Greetings
-- 
Robert Sander
Manager
Information Systems        www.epigenomics.com        Kastanienallee 24
+493024345330                                              10435 Berlin

If you have an apple and I have an apple and we exchange these apples
then you and I will still each have one apple.
But if you have an idea and I have an idea and we exchange these ideas,
then each of us will have two ideas.

George Bernard Shaw


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
