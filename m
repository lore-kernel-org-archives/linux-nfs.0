From: Bob Kryger <bobk@panix.com>
Subject: Re: nfs write problems
Date: Wed, 03 Oct 2007 13:53:13 -0400
Message-ID: <4703D709.50400@panix.com>
References: <4702A279.3080001@panix.com>
	<1191370059.6707.38.camel@heimdal.trondhjem.org>
	<47036D3F.8070904@panix.com> <20071003133118.GP21675@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: For users of Fedora <fedora-list@redhat.com>,
	nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Id8PM-0006ET-1w
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 10:53:16 -0700
Received: from mail3.panix.com ([166.84.1.74])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Id8PP-0001Cn-Tn
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 10:53:21 -0700
In-Reply-To: <20071003133118.GP21675@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Sure, easily. I gziped a capture of a single test. 
            http://www.panix.com/~bobk/typescript.gz

the program is a simple one...

#include <stdio.h>

main()

{

  unsigned long long k=0;

  unsigned char byte;

  while(!feof(stdin))

  {

    byte=getc(stdin);

    if(byte!=0)

      printf("nonzero (0%o) found at byte %d\n",byte,k);

    k++;

  }

  printf("file size = %d bytes\n",k);

}



J. Bruce Fields wrote:
> On Wed, Oct 03, 2007 at 06:21:51AM -0400, Bob Kryger wrote:
>   
>> Trond Myklebust wrote:
>>     
>>> Feel free to describe your test in a bit more detail. Without more
>>> information, we obviously can't rule out the existence of an NFS bug,
>>>   
>>>       
>> I was trying to be thorough, I hope I succeeded.
>>     
>
> The dd test sounded simple enough, but if you could include a transcript
> of the commands you ran (together with the C code of any test programs)
> just to be sure, that might help.
>
> --b.
>
>
>   


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
