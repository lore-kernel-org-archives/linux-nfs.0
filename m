From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: problem mounting using NFSv4 when using -o sec=krb5
 option
Date: Tue, 22 Mar 2005 11:12:52 -0500
Message-ID: <20050322161252.41E601BBB3@citi.umich.edu>
References: <20050322153903.42221.qmail@web51604.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDm0E-0001P9-2Q
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 08:13:10 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DDlzx-0003rW-9y
	for nfs@lists.sourceforge.net; Tue, 22 Mar 2005 08:13:09 -0800
To: mehta kiran <kiranmehta1981@yahoo.com>
In-reply-to: <20050322153903.42221.qmail@web51604.mail.yahoo.com> 
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

By convention, when creating a _service principal_, the addprinc 
"-randkey" option is used.  This option says to generate a random value 
for the initial key instead of prompting for a password.

When you do a ktadd, a new random key for that principal is generated 
and put into both the Kerberos Database and the keytab file.  Any 
previous keys for that principal become obsolete, including any keys 
generated from a password.

So, giving a password when creating a _service principal_ is useless 
because the key generated from that password becomes obsolete as soon 
as the ktadd command is done.

 
> Hi Kevin , 
>  This are some of the lines from your previos mails.
>  Sorry , but i could not digest this lines.
> ------------------
> 
> if you create a principal using a password, you should
> be able to 
> authenticate as that pricipal using that password. 
> However, once you 
> do a ktadd for that principal the password will no
> longer work.  See my 
> previous message about what ktadd does.
> 
> 
> 
> P.S.  Here is what the ktadd command does:
> - It generates a new random key value for the
>   principal (with a new key version)
> - It puts this new key into the Kerberos DB, replacing
>   any previous key with a lower kvno
> - It puts this new key into the keytab file that was
>   specified
> 
> Therefore, each time you run ktadd, the old keytab
> entry
> becomes obsolete.
> ---------------------
> Why(reason)should password become ineffective after
> ktadd ?And if that is the case , why does it ask for
> password during addprinc? continuing with this:what is
> use of this password then?
> 
> thanks,
>  --kiran
> 
> 
> 
> 
> 
> 
> 		
> __________________________________ 
> Do you Yahoo!? 
> Yahoo! Small Business - Try our new resources site!
> http://smallbusiness.yahoo.com/resources/ 




-------------------------------------------------------
This SF.net email is sponsored by: 2005 Windows Mobile Application Contest
Submit applications for Windows Mobile(tm)-based Pocket PCs or Smartphones
for the chance to win $25,000 and application distribution. Enter today at
http://ads.osdn.com/?ad_id=6882&alloc_id=15148&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
