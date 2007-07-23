From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: Re: Status of NFS over IPv6
Date: Mon, 23 Jul 2007 14:26:59 +0200
Message-ID: <46A49E93.2070306@bull.net>
References: <20070629123747.GA1034@uio.no> <46858153.8060109@oracle.com>
	<4688C70C.2050801@ext.bull.net> <4688E296.2040101@bull.net>
	<4689266A.1000607@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net, NFSv4 ML <nfsv4@linux-nfs.org>,
	=?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ICwzt-0006xZ-Sb
	for nfs@lists.sourceforge.net; Mon, 23 Jul 2007 05:26:46 -0700
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ICwzv-0006je-3J
	for nfs@lists.sourceforge.net; Mon, 23 Jul 2007 05:26:49 -0700
In-Reply-To: <4689266A.1000607@oracle.com>
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

Chuck Lever a =E9crit :

> Le Rouzic wrote:
>
>>>> While there is some interest in IPv6 among some of Linux's =

>>>> corporate sponsors, there really isn't an overwhelming "killer" =

>>>> requirement for IPv6, so there isn't much motivation to get all =

>>>> this completed.  I have to admit I'm pretty burned out on all this =

>>>> because of how complicated it has all become.  I'd be happy if =

>>>> someone stepped forward and volunteered to help or take over the =

>>>> integration.
>>>>   =

>>>
>> Some basic tests have been also done on the submitted Aur=E9lien's patchs
>> and we will be running the robustness tests we are regularly doing =

>> for ipv4.
>> See also at http://nfsv4.bullopensource.org/doc/rpc_testsuite.php
>> for this list of tests (cthon04, ffsb, fsx...)
>>
>>>
>>> We hope the interest of community about IPv6 will grow.
>>> Feel free to send comments on the code.
>>>  =

>>>
>> Some customers are already asking it but  were waiting of its =

>> availibity.
>> There are also products based on NFSV4 features which are interested in.
>
>
> Yeah, it's kind of unfortunate that we can't be completely specific =

> about the requests/requirements/use cases.


    Hi,
    I think you are right but nevertheless customers often require to be =

compliant IPV6
    in their system even they don't use IPV6. Soon, IPV6 deployed, NFS =

will be
    one of the first applications used. Some others UNIX systems also =

have it,
    so interoperabity it would be good Linux have it.
    But that is true it will be interested to know when and who on the =

nfs lists is interested in
    to use it.

> But here's what I know:
>
> 1.  Apparently there is a bureaucratic (ie non-technical) requirement =

> from the US Federal government for IPv6 support in new computer =

> software deployments.  I forget when this requirement kicks in, or =

> what exactly "IPv6 support" really entails.
>
> 2.  The APAC market wants IPv6 because of an explosion of individual =

> IP network accessors, although arguably that can be addressed for a =

> little while with judicious application of NAT routers.
>
> Otherwise, the companies I've worked for recently have had no real =

> customer requests for IPv6 support in NFS.
>
> NFS community resources are focused largely on NFSv4.1 and pNFS design =

> and implementation.  However, here's some of what I think we need to =

> get IPv6 done:
>
> +  A coherent design for handling IPv6 address caching and export =

> rules on the server side

     After a first rejected solution and some new discussion on the =

NFSV4 mailing list,
Bull (Aur=E9lien) supplied a new document described the current =

implementation. This little design document is still here: =

http://nfsv4.bullopensource.org/doc/nfs_ipv6.php

 Any new remarks are welcome.

>
> +  Help from the netdev folks with reviewing our proposed IPv6 changes

  What would be the mailing lists to call them to review?

>
> +  A cunning plan to stage the integration of all the various pieces
>
> +  Beta testers (ie real environments that can deploy NFS over IPv6 in =

> real conditions)

     May be some on this nfs mailing list have this kind of environmments.
     What  Bull can do is to run the robustness tests we are doing for =

IPV4 on IPV6.

>
> +  A whiff of project planning to help us know what the real deadlines ar
> e

 Cheers

-- =

-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic =

Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
Fax     : 33 (4) 76.29.75.18
----------------------------------------------------------------- =



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
