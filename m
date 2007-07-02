From: Le Rouzic <aime.le-rouzic@bull.net>
Subject: Re: [NFS] Status of NFS over IPv6
Date: Mon, 02 Jul 2007 13:33:42 +0200
Message-ID: <4688E296.2040101@bull.net>
References: <20070629123747.GA1034@uio.no> <46858153.8060109@oracle.com>
	<4688C70C.2050801@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
To: NFSv4 ML <nfsv4@linux-nfs.org>, nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4688C70C.2050801@ext.bull.net>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

Aur=E9lien Charbon a =E9crit :

>Chuck Lever wrote:
>
>  =

>
>>>I'd very much like to be able to sew all of this together at some point,
>>>but it's very hard to get a decent overview of it all. Does anyone =

>>>have a
>>>"current status" or "plans for the near feature" summary?
>>>      =

>>>
>>I have some patches that add IPv6 support in the RPC client.  The =

>>server is more complicated (how to deal with address-based export =

>>rules, and so on).  There hasn't been much progress on the server =

>>side, but I think Bull is still working on that.
>>    =

>>
>
>The latest server patches are on our web page. I have upgraded it.
>http://nfsv4.bullopensource.org/patches/ipv6-server/IPv6_patchset.php
>
>It includes missing parts of code. I have started from a 2.6.21 kernel + =

>Chuck patchset.
>I have send them to Bruce few weeks ago. Bruce did you received the URL =

>of new patches ?
>
>  =

>
>>Steve Dickson has added Bull's rpcbind (replacement for portmap) to =

>>Fedora 7, but there is some disagreement about whether to use a =

>>complete replacement, like rpcbind, or whether to add the needed =

>>support to the existing portmap code, in general.
>>
>>Bull has announced a test plan for user-space RPC libraries, although =

>>I haven't had a moment to look through it.  Bull should be providing =

>>testing resources once we have all of this integrated.
>>
>>    =

>>
>A student is developing a RPC/TI-RPC test suite. TI-RPC and RPCbind =

>adoption by the community has been discussed on the mailing list few =

>weeks ago.
>
>  =

>

You can visit our project web page for more information and find design =

documents at http://nfsv4.bullopensource.org/doc/rpc_testsuite.php

>>While there is some interest in IPv6 among some of Linux's corporate =

>>sponsors, there really isn't an overwhelming "killer" requirement for =

>>IPv6, so there isn't much motivation to get all this completed.  I =

>>have to admit I'm pretty burned out on all this because of how =

>>complicated it has all become.  I'd be happy if someone stepped =

>>forward and volunteered to help or take over the integration.
>>    =

>>
Some basic tests have been also done on the submitted Aur=E9lien's patchs
and we will be running the robustness tests we are regularly doing for ipv4.
See also at http://nfsv4.bullopensource.org/doc/rpc_testsuite.php
for this list of tests (cthon04, ffsb, fsx...)

>
>We hope the interest of community about IPv6 will grow.
>Feel free to send comments on the code.
>  =

>
 Some customers are already asking it but  were waiting of its availibity.
There are also products based on NFSV4 features which are interested in.

  Cheers

>  =

>
>>-------------------------------------------------------------------------
>>This SF.net email is sponsored by DB2 Express
>>Download DB2 Express C - the FREE version of DB2 express and take
>>control of your XML. No limits. Just data. Click to get it now.
>>http://sourceforge.net/powerbar/db2/
>>
>>------------------------------------------------------------------------
>>
>>_______________________________________________
>>NFS maillist  -  NFS@lists.sourceforge.net
>>https://lists.sourceforge.net/lists/listinfo/nfs
>> =

>>
>>    =

>>
>
>
>  =

>


-- =

-----------------------------------------------------------------
Company : Bull, Architect of an Open World TM (www.bull.com)
Name    : Aime Le Rouzic =

Mail    : Bull - BP 208 - 38432 Echirolles Cedex - France
E-Mail  : aime.le-rouzic@bull.net
Phone   : 33 (4) 76.29.75.51
Fax     : 33 (4) 76.29.75.18
----------------------------------------------------------------- =
