From: Tom Gundersen <teg@jklm.no>
Subject: Re: [PATCH v2] rpcbind: add support for systemd
	socket activation
Date: Sat, 4 Feb 2012 09:59:36 +0100
Message-ID: <CAG-2HqXXMFQGwT6jGsfSJRBT4fqyX0+1MueYBccqOuuz+u6P2Q@mail.gmail.com>
References: <1324602327-1789-1-git-send-email-teg@jklm.no>
	<1328096830-1383-1-git-send-email-teg@jklm.no>
	<22B77A95-49D5-4855-A230-A86C57372B28@oracle.com>
	<CAG-2HqVC3k+vmO2ieARqrKFEuP1RWZmBZ63J088DvBzSh2EdMA@mail.gmail.com>
	<59177373-E0FD-4565-94C5-E079C6BE6ED5@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1559959394=="
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	"systemd-devel@lists.freedesktop.org"
	<systemd-devel@lists.freedesktop.org>,
	libtirpc <libtirpc-devel@lists.sourceforge.net>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <systemd-devel-bounces+gcssd-systemd-devel=m.gmane.org@lists.freedesktop.org>
In-Reply-To: <59177373-E0FD-4565-94C5-E079C6BE6ED5@oracle.com>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/systemd-devel>,
	<mailto:systemd-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/systemd-devel>
List-Post: <mailto:systemd-devel@lists.freedesktop.org>
List-Help: <mailto:systemd-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/systemd-devel>,
	<mailto:systemd-devel-request@lists.freedesktop.org?subject=subscribe>
Sender: systemd-devel-bounces+gcssd-systemd-devel=m.gmane.org@lists.freedesktop.org
Errors-To: systemd-devel-bounces+gcssd-systemd-devel=m.gmane.org@lists.freedesktop.org
List-ID: <linux-nfs.vger.kernel.org>

--===============1559959394==
Content-Type: multipart/alternative; boundary=00504502e2b7192a2804b81fa67a

--00504502e2b7192a2804b81fa67a
Content-Type: text/plain; charset=UTF-8

On Friday, February 3, 2012, Chuck Lever <chuck.lever@oracle.com> wrote:
> Hi-
>
> On Feb 1, 2012, at 11:37 AM, Tom Gundersen wrote:
>
>> Hi Chuck,
>>
>> Thanks for the feedback.
>>
>> On Wed, Feb 1, 2012 at 4:32 PM, Chuck Lever <chuck.lever@oracle.com>
wrote:
>>> Typically this is done by breaking the proposed change into smaller
atomic patches.  Is that not possible in this case?
>>
>> Not entirely sure what you have in mind, I don't immediately see how
>> to split this up. Any suggestions welcome.
>>
>>>> Added Michal to cc as this patch should go a long way to sort out
>>>> <https://bugzilla.redhat.com/show_bug.cgi?id=747363>.
>>>
>>> Wouldn't comment 3 also work around problems long enough to give us an
opportunity to adequately vet the proposed changes?
>>
>> Sure, that's another option.
>>
>>> What additions to our test matrix are needed?
>>
>> I could not find any tests in the rpcbind git repo. Could you point me
>> at your test matrix?
>>
>>>> +     /* Try to find if one of the systemd sockets we were given match
>>>> +      * our netconfig structure. */
>>>> +
>>>> +     for (fd = SD_LISTEN_FDS_START; fd < SD_LISTEN_FDS_START + n;
fd++) {
>>>> +             struct __rpc_sockinfo si_other;
>>>> +             union {
>>>> +                     struct sockaddr sa;
>>>> +                     struct sockaddr_un un;
>>>> +                     struct sockaddr_in in4;
>>>> +                     struct sockaddr_in6 in6;
>>>> +                     struct sockaddr_storage storage;
>>>> +             } sa;
>>>
>>> Why is sockaddr_storage included in this union?
>>
>> This is from Lennart's original patch. Lennart, care to comment?
>>
>> For what it's worth, here is the patch with whitespace ignored, which
>> should make it simpler to review:
>>
>>
>> diff --git a/Makefile.am b/Makefile.am
>> index 9fa608e..194b467 100644
>> --- a/Makefile.am
>> +++ b/Makefile.am
>> @@ -38,6 +38,21 @@ rpcbind_SOURCES = \
>>       src/warmstart.c
>> rpcbind_LDADD = $(TIRPC_LIBS)
>>
>> +if SYSTEMD
>> +AM_CPPFLAGS += $(SYSTEMD_CFLAGS) -DSYSTEMD
>> +
>> +rpcbind_LDADD += $(SYSTEMD_LIBS)
>> +
>> +systemd/rpcbind.service: systemd/rpcbind.service.in Makefile
>> +     sed -e 's,@bindir\@,$(bindir),g' \
>> +             < $< > $@ || rm $@
>> +
>> +systemdsystemunit_DATA = \
>> +     systemd/rpcbind.service \
>> +     systemd/rpcbind.socket
>> +
>> +endif
>> +
>> rpcinfo_SOURCES =       src/rpcinfo.c
>> rpcinfo_LDADD   =       $(TIRPC_LIBS)
>>
>> diff --git a/configure.in b/configure.in
>> index 2b67720..397d52d 100644
>> --- a/configure.in
>> +++ b/configure.in
>> @@ -29,6 +29,17 @@ AC_SUBST([rpcuser], [$with_rpcuser])
>>
>> PKG_CHECK_MODULES([TIRPC], [libtirpc])
>>
>> +PKG_PROG_PKG_CONFIG
>> +AC_ARG_WITH([systemdsystemunitdir],
>> +  AS_HELP_STRING([--with-systemdsystemunitdir=DIR], [Directory for
>> systemd service files]),
>> +  [], [with_systemdsystemunitdir=$($PKG_CONFIG
>> --variable=systemdsystemunitdir systemd)])
>> +  if test "x$with_systemdsystemunitdir" != xno; then
>> +    AC_SUBST([systemdsystemunitdir], [$with_systemdsystemunitdir])
>> +    PKG_CHECK_MODULES([SYSTEMD], [libsystemd-daemon])
>> +  fi
>> +AM_CONDITIONAL(SYSTEMD, [test -n "$with_systemdsystemunitdir" -a
>> "x$with_systemdsystemunitdir" != xno ])
>> +
>> +
>> AS_IF([test x$enable_libwrap = xyes], [
>>       AC_CHECK_LIB([wrap], [hosts_access], ,
> It's not clear to me how this works on a system that does not have
libsystemd-daemon installed.  It appears to require
"--with-systemdsystemunitdir=no" which a) is not documented that I can see,
b) is awkward ("no" is not a directory name), and c) violates the principal
of least surprise.
>
> Our usual practice is to add features so they are enabled when they find
all of the dependencies already on the build system, and they are disabled
otherwise.  configure options are used to force the situation, but out of
the shrink wrap, configure should just work.
>
> This way, typically applying a patch does not require any changes to RPMs
or other automated build infrastructure except in rare circumstances.
>
> Did I miss something?

You are right, that's a bug. I'll fix this when I resubmit.

Thanks for testing,

Tom


>> diff --git a/src/rpcbind.c b/src/rpcbind.c
>> index 24e069b..a87ce05 100644
>> --- a/src/rpcbind.c
>> +++ b/src/rpcbind.c
>> @@ -56,6 +56,9 @@
>> #include <netinet/in.h>
>> #endif
>> #include <arpa/inet.h>
>> +#ifdef SYSTEMD
>> +#include <systemd/sd-daemon.h>
>> +#endif
>> #include <fcntl.h>
>> #include <netdb.h>
>> #include <stdio.h>
>> @@ -281,6 +284,7 @@ init_transport(struct netconfig *nconf)
>>       u_int32_t host_addr[4];  /* IPv4 or IPv6 */
>>       struct sockaddr_un sun;
>>       mode_t oldmask;
>> +     int n = 0;
>>         res = NULL;
>>
>>       if ((nconf->nc_semantics != NC_TPI_CLTS) &&
>> @@ -300,6 +304,76 @@ init_transport(struct netconfig *nconf)
>>       }
>> #endif
>>
>> +     if (!__rpc_nconf2sockinfo(nconf, &si)) {
>> +             syslog(LOG_ERR, "cannot get information for %s",
>> +                 nconf->nc_netid);
>> +             return (1);
>> +     }
>> +
>> +#ifdef SYSTEMD
>> +     n = sd_listen_fds(0);
>> +     if (n < 0) {
>> +             syslog(LOG_ERR, "failed to acquire systemd scokets: %s",
strerror(-n));
>> +             return 1;
>> +     }
>> +
>> +     /* Try to find if one of the systemd sockets we were given match
>> +      * our netconfig structure. */
>> +
>> +     for (fd = SD_LISTEN_FDS_START; fd < SD_LISTEN_FDS_START + n; fd++)
{
>> +             struct __rpc_sockinfo si_other;
>> +             union {
>> +                     struct sockaddr sa;
>> +                     struct sockaddr_un un;
>> +                     struct sockaddr_in in4;
>> +                     struct sockaddr_in6 in6;
>> +                     struct sockaddr_storage storage;
>> +             } sa;
>> +             socklen_t addrlen = sizeof(sa);
>> +
>> +             if (!__rpc_fd2sockinfo(fd, &si_other)) {
>> +                     syslog(LOG_ERR, "cannot get information for fd
%i", fd);
>> +                     return 1;
>> +             }
>> +
>> +             if (si.si_af != si_other.si_af ||
>> +                    si.si_socktype != si_other.si_socktype ||
>> +                    si.si_proto != si_other.si_proto)
>> +                     continue;
>> +
>> +             if (getsockname(fd, &sa.sa, &addrlen) < 0) {
>> +                     syslog(LOG_ERR, "failed to query socket name: %s",
>> +                               strerror(errno));
>> +                     goto error;
>> +             }
>> +
>> +             /* Copy the address */
>> +             taddr.addr.maxlen = taddr.addr.len = addrlen;
>> +             taddr.addr.buf = malloc(addrlen);
>> +             if (taddr.addr.buf == NULL) {
>> +                     syslog(LOG_ERR,
>> +                               "cannot allocate memory for

--00504502e2b7192a2804b81fa67a
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<br><br>On Friday, February 3, 2012, Chuck Lever &lt;<a href=3D"mailto:chuc=
k.lever@oracle.com">chuck.lever@oracle.com</a>&gt; wrote:<br>&gt; Hi-<br>&g=
t;<br>&gt; On Feb 1, 2012, at 11:37 AM, Tom Gundersen wrote:<br>&gt;<br>&gt=
;&gt; Hi Chuck,<br>
&gt;&gt;<br>&gt;&gt; Thanks for the feedback.<br>&gt;&gt;<br>&gt;&gt; On We=
d, Feb 1, 2012 at 4:32 PM, Chuck Lever &lt;<a href=3D"mailto:chuck.lever@or=
acle.com">chuck.lever@oracle.com</a>&gt; wrote:<br>&gt;&gt;&gt; Typically t=
his is done by breaking the proposed change into smaller atomic patches. =
=C2=A0Is that not possible in this case?<br>
&gt;&gt;<br>&gt;&gt; Not entirely sure what you have in mind, I don&#39;t i=
mmediately see how<br>&gt;&gt; to split this up. Any suggestions welcome.<b=
r>&gt;&gt;<br>&gt;&gt;&gt;&gt; Added Michal to cc as this patch should go a=
 long way to sort out<br>
&gt;&gt;&gt;&gt; &lt;<a href=3D"https://bugzilla.redhat.com/show_bug.cgi?id=
=3D747363">https://bugzilla.redhat.com/show_bug.cgi?id=3D747363</a>&gt;.<br=
>&gt;&gt;&gt;<br>&gt;&gt;&gt; Wouldn&#39;t comment 3 also work around probl=
ems long enough to give us an opportunity to adequately vet the proposed ch=
anges?<br>
&gt;&gt;<br>&gt;&gt; Sure, that&#39;s another option.<br>&gt;&gt;<br>&gt;&g=
t;&gt; What additions to our test matrix are needed?<br>&gt;&gt;<br>&gt;&gt=
; I could not find any tests in the rpcbind git repo. Could you point me<br=
>
&gt;&gt; at your test matrix?<br>&gt;&gt;<br>&gt;&gt;&gt;&gt; + =C2=A0 =C2=
=A0 /* Try to find if one of the systemd sockets we were given match<br>&gt=
;&gt;&gt;&gt; + =C2=A0 =C2=A0 =C2=A0* our netconfig structure. */<br>&gt;&g=
t;&gt;&gt; +<br>&gt;&gt;&gt;&gt; + =C2=A0 =C2=A0 for (fd =3D SD_LISTEN_FDS_=
START; fd &lt; SD_LISTEN_FDS_START + n; fd++) {<br>
&gt;&gt;&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct __rpc_s=
ockinfo si_other;<br>&gt;&gt;&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 union {<br>&gt;&gt;&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct sockaddr sa;<br>&gt;&gt;&gt;&gt; + =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struc=
t sockaddr_un un;<br>
&gt;&gt;&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 struct sockaddr_in in4;<br>&gt;&gt;&gt;&gt; + =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct sockaddr_in6=
 in6;<br>&gt;&gt;&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 struct sockaddr_storage storage;<br>&gt;&gt;&gt;&g=
t; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } sa;<br>
&gt;&gt;&gt;<br>&gt;&gt;&gt; Why is sockaddr_storage included in this union=
?<br>&gt;&gt;<br>&gt;&gt; This is from Lennart&#39;s original patch. Lennar=
t, care to comment?<br>&gt;&gt;<br>&gt;&gt; For what it&#39;s worth, here i=
s the patch with whitespace ignored, which<br>
&gt;&gt; should make it simpler to review:<br>&gt;&gt;<br>&gt;&gt;<br>&gt;&=
gt; diff --git a/Makefile.am b/Makefile.am<br>&gt;&gt; index 9fa608e..194b4=
67 100644<br>&gt;&gt; --- a/Makefile.am<br>&gt;&gt; +++ b/Makefile.am<br>
&gt;&gt; @@ -38,6 +38,21 @@ rpcbind_SOURCES =3D \<br>&gt;&gt; =C2=A0 =C2=A0=
 =C2=A0 src/warmstart.c<br>&gt;&gt; rpcbind_LDADD =3D $(TIRPC_LIBS)<br>&gt;=
&gt;<br>&gt;&gt; +if SYSTEMD<br>&gt;&gt; +AM_CPPFLAGS +=3D $(SYSTEMD_CFLAGS=
) -DSYSTEMD<br>&gt;&gt; +<br>
&gt;&gt; +rpcbind_LDADD +=3D $(SYSTEMD_LIBS)<br>&gt;&gt; +<br>&gt;&gt; +sys=
temd/rpcbind.service: systemd/<a href=3D"http://rpcbind.service.in">rpcbind=
.service.in</a> Makefile<br>&gt;&gt; + =C2=A0 =C2=A0 sed -e &#39;s,@bindir\=
@,$(bindir),g&#39; \<br>
&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 &lt; $&lt; &gt; $@ || =
rm $@<br>&gt;&gt; +<br>&gt;&gt; +systemdsystemunit_DATA =3D \<br>&gt;&gt; +=
 =C2=A0 =C2=A0 systemd/rpcbind.service \<br>&gt;&gt; + =C2=A0 =C2=A0 system=
d/rpcbind.socket<br>&gt;&gt; +<br>&gt;&gt; +endif<br>
&gt;&gt; +<br>&gt;&gt; rpcinfo_SOURCES =3D =C2=A0 =C2=A0 =C2=A0 src/rpcinfo=
.c<br>&gt;&gt; rpcinfo_LDADD =C2=A0 =3D =C2=A0 =C2=A0 =C2=A0 $(TIRPC_LIBS)<=
br>&gt;&gt;<br>&gt;&gt; diff --git a/<a href=3D"http://configure.in">config=
ure.in</a> b/<a href=3D"http://configure.in">configure.in</a><br>
&gt;&gt; index 2b67720..397d52d 100644<br>&gt;&gt; --- a/<a href=3D"http://=
configure.in">configure.in</a><br>&gt;&gt; +++ b/<a href=3D"http://configur=
e.in">configure.in</a><br>&gt;&gt; @@ -29,6 +29,17 @@ AC_SUBST([rpcuser], [=
$with_rpcuser])<br>
&gt;&gt;<br>&gt;&gt; PKG_CHECK_MODULES([TIRPC], [libtirpc])<br>&gt;&gt;<br>=
&gt;&gt; +PKG_PROG_PKG_CONFIG<br>&gt;&gt; +AC_ARG_WITH([systemdsystemunitdi=
r],<br>&gt;&gt; + =C2=A0AS_HELP_STRING([--with-systemdsystemunitdir=3DDIR],=
 [Directory for<br>
&gt;&gt; systemd service files]),<br>&gt;&gt; + =C2=A0[], [with_systemdsyst=
emunitdir=3D$($PKG_CONFIG<br>&gt;&gt; --variable=3Dsystemdsystemunitdir sys=
temd)])<br>&gt;&gt; + =C2=A0if test &quot;x$with_systemdsystemunitdir&quot;=
 !=3D xno; then<br>
&gt;&gt; + =C2=A0 =C2=A0AC_SUBST([systemdsystemunitdir], [$with_systemdsyst=
emunitdir])<br>&gt;&gt; + =C2=A0 =C2=A0PKG_CHECK_MODULES([SYSTEMD], [libsys=
temd-daemon])<br>&gt;&gt; + =C2=A0fi<br>&gt;&gt; +AM_CONDITIONAL(SYSTEMD, [=
test -n &quot;$with_systemdsystemunitdir&quot; -a<br>
&gt;&gt; &quot;x$with_systemdsystemunitdir&quot; !=3D xno ])<br>&gt;&gt; +<=
br>&gt;&gt; +<br>&gt;&gt; AS_IF([test x$enable_libwrap =3D xyes], [<br>&gt;=
&gt; =C2=A0 =C2=A0 =C2=A0 AC_CHECK_LIB([wrap], [hosts_access], ,<br>&gt; It=
&#39;s not clear to me how this works on a system that does not have libsys=
temd-daemon installed. =C2=A0It appears to require &quot;--with-systemdsyst=
emunitdir=3Dno&quot; which a) is not documented that I can see, b) is awkwa=
rd (&quot;no&quot; is not a directory name), and c) violates the principal =
of least surprise.<br>
&gt;<br>&gt; Our usual practice is to add features so they are enabled when=
 they find all of the dependencies already on the build system, and they ar=
e disabled otherwise. =C2=A0configure options are used to force the situati=
on, but out of the shrink wrap, configure should just work.<br>
&gt;<br>&gt; This way, typically applying a patch does not require any chan=
ges to RPMs or other automated build infrastructure except in rare circumst=
ances.<br>&gt;<br>&gt; Did I miss something?<br><br>You are right, that&#39=
;s a bug. I&#39;ll fix this when I resubmit.<br>
<br>Thanks for testing,<br><br>Tom<br><br><br>&gt;&gt; diff --git a/src/rpc=
bind.c b/src/rpcbind.c<br>&gt;&gt; index 24e069b..a87ce05 100644<br>&gt;&gt=
; --- a/src/rpcbind.c<br>&gt;&gt; +++ b/src/rpcbind.c<br>&gt;&gt; @@ -56,6 =
+56,9 @@<br>
&gt;&gt; #include &lt;netinet/in.h&gt;<br>&gt;&gt; #endif<br>&gt;&gt; #incl=
ude &lt;arpa/inet.h&gt;<br>&gt;&gt; +#ifdef SYSTEMD<br>&gt;&gt; +#include &=
lt;systemd/sd-daemon.h&gt;<br>&gt;&gt; +#endif<br>&gt;&gt; #include &lt;fcn=
tl.h&gt;<br>
&gt;&gt; #include &lt;netdb.h&gt;<br>&gt;&gt; #include &lt;stdio.h&gt;<br>&=
gt;&gt; @@ -281,6 +284,7 @@ init_transport(struct netconfig *nconf)<br>&gt;=
&gt; =C2=A0 =C2=A0 =C2=A0 u_int32_t host_addr[4]; =C2=A0/* IPv4 or IPv6 */<=
br>&gt;&gt; =C2=A0 =C2=A0 =C2=A0 struct sockaddr_un sun;<br>
&gt;&gt; =C2=A0 =C2=A0 =C2=A0 mode_t oldmask;<br>&gt;&gt; + =C2=A0 =C2=A0 i=
nt n =3D 0;<br>&gt;&gt; =C2=A0 =C2=A0 =C2=A0 =C2=A0 res =3D NULL;<br>&gt;&g=
t;<br>&gt;&gt; =C2=A0 =C2=A0 =C2=A0 if ((nconf-&gt;nc_semantics !=3D NC_TPI=
_CLTS) &amp;&amp;<br>&gt;&gt; @@ -300,6 +304,76 @@ init_transport(struct ne=
tconfig *nconf)<br>
&gt;&gt; =C2=A0 =C2=A0 =C2=A0 }<br>&gt;&gt; #endif<br>&gt;&gt;<br>&gt;&gt; =
+ =C2=A0 =C2=A0 if (!__rpc_nconf2sockinfo(nconf, &amp;si)) {<br>&gt;&gt; + =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 syslog(LOG_ERR, &quot;cannot get =
information for %s&quot;,<br>&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 nconf-&gt;nc_netid);<br>
&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return (1);<br>&gt;&gt=
; + =C2=A0 =C2=A0 }<br>&gt;&gt; +<br>&gt;&gt; +#ifdef SYSTEMD<br>&gt;&gt; +=
 =C2=A0 =C2=A0 n =3D sd_listen_fds(0);<br>&gt;&gt; + =C2=A0 =C2=A0 if (n &l=
t; 0) {<br>&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 syslog(LOG_=
ERR, &quot;failed to acquire systemd scokets: %s&quot;, strerror(-n));<br>
&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 1;<br>&gt;&gt; =
+ =C2=A0 =C2=A0 }<br>&gt;&gt; +<br>&gt;&gt; + =C2=A0 =C2=A0 /* Try to find =
if one of the systemd sockets we were given match<br>&gt;&gt; + =C2=A0 =C2=
=A0 =C2=A0* our netconfig structure. */<br>&gt;&gt; +<br>&gt;&gt; + =C2=A0 =
=C2=A0 for (fd =3D SD_LISTEN_FDS_START; fd &lt; SD_LISTEN_FDS_START + n; fd=
++) {<br>
&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct __rpc_sockinfo =
si_other;<br>&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 union {<b=
r>&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 struct sockaddr sa;<br>&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct sockaddr_un un;<br>&gt;&gt; +=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 stru=
ct sockaddr_in in4;<br>
&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 struct sockaddr_in6 in6;<br>&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 struct sockaddr_storage storage;<=
br>&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 } sa;<br>&gt;&gt; +=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 socklen_t addrlen =3D sizeof(sa)=
;<br>&gt;&gt; +<br>
&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!__rpc_fd2sockinfo=
(fd, &amp;si_other)) {<br>&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 syslog(LOG_ERR, &quot;cannot get informatio=
n for fd %i&quot;, fd);<br>&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 1;<br>&gt;&gt; + =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 }<br>
&gt;&gt; +<br>&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (si.s=
i_af !=3D si_other.si_af ||<br>&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0si.si_socktype !=3D si_other.si_sockt=
ype ||<br>&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0si.si_proto !=3D si_other.si_proto)<br>&gt;&gt; + =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 continue;<br=
>
&gt;&gt; +<br>&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (gets=
ockname(fd, &amp;<a href=3D"http://sa.sa">sa.sa</a>, &amp;addrlen) &lt; 0) =
{<br>&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 syslog(LOG_ERR, &quot;failed to query socket name: %s&quot;,<br>=
&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 strerror(errno));<br>
&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto error;<br>&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
}<br>&gt;&gt; +<br>&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* =
Copy the address */<br>&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 taddr.addr.maxlen =3D taddr.addr.len =3D addrlen;<br>&gt;&gt; + =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 taddr.addr.buf =3D malloc(addrlen);<br>
&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (taddr.addr.buf =3D=
=3D NULL) {<br>&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 syslog(LOG_ERR,<br>&gt;&gt; + =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 &quot;cannot allocate memory for <br>

--00504502e2b7192a2804b81fa67a--

--===============1559959394==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
systemd-devel mailing list
systemd-devel@lists.freedesktop.org
http://lists.freedesktop.org/mailman/listinfo/systemd-devel

--===============1559959394==--
