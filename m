From: parinay <parinay@gmail.com>
Subject: Re: PyNFS
Date: Wed, 24 May 2006 13:07:34 +0530
Message-ID: <ea2ed4af0605240037h6f706bcre628a991de7b96a7@mail.gmail.com>
References: <ea2ed4af0605232059r56854793s8b7fef615dc587d3@mail.gmail.com>
	 <Pine.LNX.4.64.0605240919340.6128@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----=_Part_155324_18475350.1148456254859"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Finw2-0007aW-Ir
	for nfs@lists.sourceforge.net; Wed, 24 May 2006 00:37:38 -0700
Received: from wx-out-0102.google.com ([66.249.82.203])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Finw0-0004EK-U0
	for nfs@lists.sourceforge.net; Wed, 24 May 2006 00:37:38 -0700
Received: by wx-out-0102.google.com with SMTP id s10so804527wxc
        for <nfs@lists.sourceforge.net>; Wed, 24 May 2006 00:37:35 -0700 (PDT)
To: "=?ISO-8859-1?Q?Peter_=C5strand?=" <astrand@cendio.se>
In-Reply-To: <Pine.LNX.4.64.0605240919340.6128@maggie.lkpg.cendio.se>
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

------=_Part_155324_18475350.1148456254859
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Peter,
Sorry to bother you.
I am attempting to run, PyNFS and it is giving me tracebacks, I dont know
python at all.
Can you help me, getting it run ?

Following are the things that I have tried,
                    -As per the steps, executed, rpcgen.py  nfs4.x and
./setup.py install
                    -The binaries are installed @ ~python/bin

Hereafter i I try to run the nfs4stest, it give this trace back.Same is the
case for test_tree_net.py

My objective is to run this , on NetApp filer, from Linux/solaris NFS
client.
Please let me know, If I am missing something or If you want some more
information on this.
Awaiting.

thanks & regards
parina

-----------------snippet---------------------------------------------------=
---------
[zorba@akam bin]$ ./test_tree_net.py 10.55.63.1 /mnt/test/
sys:1: DeprecationWarning: Non-ASCII character '\xc5' in file
./test_tree_net.py on line 5, but no encoding declared; see
http://www.python.org/peps/pep-0263.html for details
10.55.63.1 None
Traceback (most recent call last):
  File "./test_tree_net.py", line 426, in ?
    main(ncl, directory)
  File "./test_tree_net.py", line 91, in main
    ncl.init_connection()
  File "/root/python/lib/python/nfs4lib.py", line 538, in init_connection

  File "/root/python/lib/python/nfs4lib.py", line 793, in check_result

nfs4lib.BadCompoundRes: operation OP_SETCLIENTID returned result
NFS4ERR_INVAL
[zorba@akam bin]

[zorba@akam bin]$ ./nfs4stest.py nfs://myfiler:2049  -t -v st_lock

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
ERROR: LOCK range over 32 bits should work or return NFS4ERR_BAD_RANGE
----------------------------------------------------------------------
Traceback (most recent call last):
  File "/root/python/lib/python/nfs4st/st_lock.py", line 12, in setUp
    self.init_connection()
  File "/root/python/lib/python/nfs4st/base_st_classes.py", line 540, in
init_connection
    self.failIfRaises(rpc.RPCException, ncl.init_connection,*args,**kwargs)
  File "/root/python/lib/python/nfs4st/base_st_classes.py", line 493, in
failIfRaises
    self.fail(e)
  File "/usr/src/build/475206-i386/install/usr/lib/python2.3/unittest.py",
line 270, in fail
    raise self.failureException, msg
AssertionError: operation OP_SETCLIENTID returned result NFS4ERR_INVAL

On 5/24/06, Peter =C5strand <astrand@cendio.se> wrote:
>
> > Any help on PyNFS for NFSv2 NFSv3 ??
> > I have downloaded  PyNFS for NFSv4.In process of onfiguring and running
it.
> > Any help on that will also be very much helpfull.
>
> I haven't looked at PyNFS for two years, but then, I was able to generate
> Python code for the mount protocol, by using rpcgen.py. This "mount
> client" can be found in the UNFS3 CVS.
>
> Don't know about the rest of NFSv2/v3, though.
>
> Kind regards,
> --
> Peter =C5strand           ThinLinc Chief Developer
> Cendio                  http://www.cendio.se
> Teknikringen 3
> 583 30 Link=F6ping        Phone: +46-13-21 46 00
>


--=20
easy is right
begin right and you're easy
continue easy and you're right
the right way to go easy is to forget the right way
and forget that the going is easy....

------=_Part_155324_18475350.1148456254859
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Peter,<br>Sorry to bother you.<br>I am attempting to run, PyNFS and it is g=
iving me tracebacks, I dont know python at all.<br>Can you help me, getting=
 it run ?<br><br>Following are the things that I have tried,<br>&nbsp;&nbsp=
;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&n=
bsp;&nbsp;&nbsp;&nbsp;&nbsp; -As per the steps, executed,=20
rpcgen.py&nbsp;&nbsp;nfs4.x and ./setup.py install<br>&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp; -The binaries are installed @ ~python/bin<br><br>Hereaft=
er i I try to run the nfs4stest, it give this trace back.Same is the case f=
or test_tree_net.py<br><br>
My objective is to run this , on NetApp filer, from Linux/solaris NFS clien=
t.<br>Please let me know, If I am missing something or If you want some mor=
e information on this.<br>Awaiting.<br><br>thanks &amp; regards<br>parina
<br><br>-----------------snippet-------------------------------------------=
-----------------<br>[zorba@akam bin]$ ./test_tree_net.py <a href=3D"http:/=
/10.55.63.1">10.55.63.1</a> /mnt/test/<br>sys:1: DeprecationWarning: Non-AS=
CII character '\xc5' in file ./test_tree_net.py on line 5, but no encoding =
declared; see=20
<a href=3D"http://www.python.org/peps/pep-0263.html">http://www.python.org/=
peps/pep-0263.html</a> for details<br><a href=3D"http://10.55.63.1">10.55.6=
3.1</a> None<br>Traceback (most recent call last):<br>&nbsp;&nbsp;File &quo=
t;./test_tree_net.py&quot;, line 426, in ?
<br>&nbsp;&nbsp;&nbsp;&nbsp;main(ncl, directory)<br>&nbsp;&nbsp;File &quot;=
./test_tree_net.py&quot;, line 91, in main<br>&nbsp;&nbsp;&nbsp;&nbsp;ncl.i=
nit_connection()<br>&nbsp;&nbsp;File &quot;/root/python/lib/python/nfs4lib.=
py&quot;, line 538, in init_connection<br><br>&nbsp;&nbsp;File &quot;/root/=
python/lib/python/nfs4lib.py&quot;, line 793, in check_result
<br><br>nfs4lib.BadCompoundRes: operation OP_SETCLIENTID returned result NF=
S4ERR_INVAL<br>[zorba@akam bin]<br><br>[zorba@akam bin]$ ./nfs4stest.py nfs=
://myfiler:2049&nbsp;&nbsp;-t -v st_lock <br><br>=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
<br>ERROR: LOCK range over 32 bits should work or return NFS4ERR_BAD_RANGE<=
br>----------------------------------------------------------------------<b=
r>Traceback (most recent call last):<br>&nbsp;&nbsp;File &quot;/root/python=
/lib/python/nfs4st/st_lock.py&quot;, line 12, in setUp
<br>&nbsp;&nbsp;&nbsp;&nbsp;self.init_connection()<br>&nbsp;&nbsp;File &quo=
t;/root/python/lib/python/nfs4st/base_st_classes.py&quot;, line 540, in ini=
t_connection<br>&nbsp;&nbsp;&nbsp;&nbsp;self.failIfRaises(rpc.RPCException,=
 ncl.init_connection,*args,**kwargs)<br>&nbsp;&nbsp;File &quot;/root/python=
/lib/python/nfs4st/base_st_classes.py&quot;, line 493, in failIfRaises
<br>&nbsp;&nbsp;&nbsp;&nbsp;self.fail(e)<br>&nbsp;&nbsp;File &quot;/usr/src=
/build/475206-i386/install/usr/lib/python2.3/unittest.py&quot;, line 270, i=
n fail<br>&nbsp;&nbsp;&nbsp;&nbsp;raise self.failureException, msg<br>Asser=
tionError: operation OP_SETCLIENTID returned result NFS4ERR_INVAL
<br><br>On 5/24/06, Peter =C5strand &lt;<a href=3D"mailto:astrand@cendio.se=
">astrand@cendio.se</a>&gt; wrote:<br>&gt; <br>&gt; &gt; Any help on PyNFS =
for NFSv2 NFSv3 ??<br>&gt; &gt; I have downloaded&nbsp;&nbsp;PyNFS for NFSv=
4.In process of onfiguring and running it.
<br>&gt; &gt; Any help on that will also be very much helpfull.<br>&gt; <br=
>&gt; I haven't looked at PyNFS for two years, but then, I was able to gene=
rate<br>&gt; Python code for the mount protocol, by using rpcgen.py. This &=
quot;mount
<br>&gt; client&quot; can be found in the UNFS3 CVS.<br>&gt; <br>&gt; Don't=
 know about the rest of NFSv2/v3, though.<br>&gt; <br>&gt; Kind regards,<br=
>&gt; --<br>&gt; Peter =C5strand&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;&nbsp;&nbsp; ThinLinc Chief Developer<br>&gt; Cendio&nbsp;&nbsp;&nbsp;=
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;
<a href=3D"http://www.cendio.se">http://www.cendio.se</a><br>&gt; Teknikrin=
gen 3<br>&gt; 583 30 Link=F6ping&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&=
nbsp;Phone: +46-13-21 46 00<br>&gt; <br><br><br>-- <br>easy is right<br>beg=
in right and you're easy<br>continue easy and you're right
<br>the right way to go easy is to forget the right way<br>and forget that =
the going is easy....<br><br>

------=_Part_155324_18475350.1148456254859--


-------------------------------------------------------
All the advantages of Linux Managed Hosting--Without the Cost and Risk!
Fully trained technicians. The highest number of Red Hat certifications in
the hosting industry. Fanatical Support. Click to learn more
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=107521&bid=248729&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
