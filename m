From: Dan Brunner <daniel.brunner@duni.com>
Subject: Re: 32k NFS blocksize not working
Date: Wed, 12 Mar 2003 16:22:00 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <0B0C2A88-54D9-11D7-9527-00306589E6DA@duni.com>
References: <1047506146.6666.11.camel@batman.ece.rice.edu>
Mime-Version: 1.0 (Apple Message framework v551)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [65.168.147.194] (helo=mkeweb01.duni.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18tEbu-00022I-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Mar 2003 14:22:06 -0800
To: bclem@rice.edu
In-Reply-To: <1047506146.6666.11.camel@batman.ece.rice.edu>
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

I believe your running UDP.

Try running it over TCP, and see what you get...


Dan


On Wednesday, March 12, 2003, at 03:55  PM, bclem@rice.edu wrote:

> We have a linux server running 2.4.20 plus it has nfsv3 udp/tcp server
> support compiled in.
>
> We have a linux client running 2.4.20 plus it has nfsv3 udp/tcp client
> support compiled.
>
>
> If we specify a read/write size above 8192 on the client, and then 
> mount
> the nfs directory. It gives us the following on /proc/mounts
>
>
> cluster:/usr/local/ /tmp/d nfs
> rw,v3,rsize=8192,wsize=8192,hard,udp,lock,addr=cluster 0 0
>
> Do we have to edit something in a kernel include file to allow NFSV3 to
> mount above 8k?
>
> Thanks,
> Brent
>
>
>
>
>
> -------------------------------------------------------
> This SF.net email is sponsored by:Crypto Challenge is now open!
> Get cracking and register here for some mind boggling fun and
> the chance of winning an Apple iPod:
> http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This SF.net email is sponsored by:Crypto Challenge is now open! 
Get cracking and register here for some mind boggling fun and 
the chance of winning an Apple iPod:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0031en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
