From: "Jose R. Santos" <jrsantos@austin.ibm.com>
Subject: Re: Problems with NFS while running SpecSFS with JFS filesystem and 2.6 kernel.
Date: Thu, 11 Dec 2003 09:13:31 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031211151331.GA7920@dbz.austin.ibm.com>
References: <20031210144011.GE708@dbz.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AUSVY-0005BV-IY
	for nfs@lists.sourceforge.net; Thu, 11 Dec 2003 07:13:40 -0800
Received: from e34.co.us.ibm.com ([32.97.110.132])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.24)
	id 1AUSVX-0005dw-W5
	for nfs@lists.sourceforge.net; Thu, 11 Dec 2003 07:13:40 -0800
To: "Jose R. Santos" <jrsantos@austin.ibm.com>
In-Reply-To: <20031210144011.GE708@dbz.austin.ibm.com> (from jrsantos@austin.ibm.com on Wed, Dec 10, 2003 at 08:40:11 -0600)
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

On 12/10/03 08:40:11, Jose R. Santos wrote:
>      >>>Dec  9 14:48:04 onus kernel: nfsd: LOOKUP(3)   20: 01000001 00420051 00000002 0000a17e 00009083 00000000 file_en.46340
>      >>>Dec  9 14:48:04 onus kernel: nfsd: LOOKUP(3)   20: 01000001 00420051 00000002 0000a17e 00009083 00000000 file_en.46410

I'm looking at the NFSd code and I think I'm getting a little confuse
and since I'm not a NFS expert, I don't know if something like the above
two lines is OK or not.

Can someone impose a bit of wisdom on me. :)

-JRS


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
