Return-Path: nfsv4-bounces@ietf.org
Date: Wed, 28 Jan 2015 18:44:10 -0500
Message-ID: <CAN-5tyFmf8jtzfV1NEu6ZmL_OdGgEvutXBm7HUwXk0SNLXzyPQ@mail.gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
To: "nfsv4@ietf.org" <nfsv4@ietf.org>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: [nfsv4] protocol question about delegation stateid
List-Unsubscribe: <https://www.ietf.org/mailman/options/nfsv4>,
 <mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www.ietf.org/mail-archive/web/nfsv4/>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
 <mailto:nfsv4-request@ietf.org?subject=subscribe>
Content-Type: multipart/mixed; boundary="===============3010472451032276099=="
Errors-To: nfsv4-bounces@ietf.org
Sender: "nfsv4" <nfsv4-bounces@ietf.org>
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

--===============3010472451032276099==
Content-Type: multipart/alternative; boundary=001a11c3c34ab43075050dbef240

--001a11c3c34ab43075050dbef240
Content-Type: text/plain; charset=UTF-8

Hi folks,

Can somebody clarify if the server is *required* to update the sequence
number of the delegation stateid when it receives an OPEN for which it has
already gave out a delegation before? Client sends one OPEN and server
gives out a delegation, then client sends another OPEN and server is
choosing returning a delegation again.

If the server is not required to update the delegation stateid sequence,
there is a problem with a racing DELEGRETURN and another OPEN from the same
file. Client is in the process of returning a delegation (due to resource
constraints) and a different thread on the client is opening the same file
it (had) the delegation for (at this point the client doesn't see the
delegation and thus sends the open request to the server). The server can
get the OPEN before the DELEGRETURN and from server's perspective it knows
the client has a delegation. If it does not increment the seqnumber when it
returns a delegation in OPEN, when the server receives a DELEGRETURN, the
server assumes the client is returning the delegation. However, the client
finishes processing the reply from the OPEN and stores the delegation. The
use of this delegation later results in BAD_STATEID error.

Let me state that server does have an option of not returning a delegation
to the client in this case. However, then the new open would lack the
benefits of a delegation and perhaps this should be acceptable solution to
deal with the race.

There is a general wording from the definition of the stateid that implies
that seqnumber should be incremented since delegation stateid is a stateid.
Handling of open stateids and need for incrementing is more clearly
specified in the spec.

from rfc 3530 (same wording in rfc 5661)
stateid4

                  struct stateid4 {
                    uint32_t        seqid;
                    opaque          other[12];
                  };

   This structure is used for the various state sharing mechanisms
   between the client and server.  For the client, this data structure
   is read-only.  The starting value of the seqid field is undefined.

*The server is required to increment the seqid field monotonically at
 each transition of the stateid.*

What should the server behavior be when it receives an OPEN for which it
already gave out a delegation?

Thank you.

--001a11c3c34ab43075050dbef240
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Dutf-8"><d=
iv dir=3D"ltr">Hi folks,<br><br>Can somebody clarify if the server is *requ=
ired* to update the sequence number of the delegation stateid when it recei=
ves an OPEN for which it has already gave out a delegation before? Client s=
ends one OPEN and server gives out a delegation, then client sends another =
OPEN and server is choosing returning a delegation again.<br><br>If the ser=
ver is not required to update the delegation stateid sequence, there is a p=
roblem with a racing DELEGRETURN and another OPEN from the same file. Clien=
t is in the process of returning a delegation (due to resource constraints)=
 and a different thread on the client is opening the same file it (had) the=
 delegation for (at this point the client doesn't see the delegation and th=
us sends the open request to the server). The server can get the OPEN befor=
e the DELEGRETURN and from server's perspective it knows the client has a d=
elegation. If it does not increment the seqnumber when it returns a delegat=
ion in OPEN, when the server receives a DELEGRETURN, the server assumes the=
 client is returning the delegation. However, the client finishes processin=
g the reply from the OPEN and stores the delegation. The use of this delega=
tion later results in BAD_STATEID error.<br><br>Let me state that server do=
es have an option of not returning a delegation to the client in this case.=
 However, then the new open would lack the benefits of a delegation and per=
haps this should be acceptable solution to deal with the race.<div><br>Ther=
e is a general wording from the definition of the stateid that implies that=
 seqnumber should be incremented since delegation stateid is a stateid. Han=
dling of open stateids and need for incrementing is more clearly specified =
in the spec.&nbsp;<br><br>from rfc 3530 (same wording in rfc 5661)<br>state=
id4<br><br>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; s=
truct stateid4 {<br>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;=
 &nbsp; &nbsp; uint32_t &nbsp; &nbsp; &nbsp; &nbsp;seqid;<br>&nbsp; &nbsp; =
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; opaque &nbsp; &nbsp=
; &nbsp; &nbsp; &nbsp;other[12];<br>&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbs=
p; &nbsp; &nbsp; &nbsp; };<br><br>&nbsp; &nbsp;This structure is used for t=
he various state sharing mechanisms<br>&nbsp; &nbsp;between the client and =
server.&nbsp; For the client, this data structure<br>&nbsp; &nbsp;is read-o=
nly.&nbsp; The starting value of the seqid field is undefined.<br>&nbsp; &n=
bsp;<u>The server is required to increment the seqid field monotonically at=
<br>&nbsp; &nbsp;each transition of the stateid.</u><div><u><br></u></div><=
div>What should the server behavior be when it receives an OPEN for which i=
t already gave out a delegation? &nbsp;<br><br></div><div>Thank you.</div><=
/div></div>

--001a11c3c34ab43075050dbef240--

--===============3010472451032276099==
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4

--===============3010472451032276099==--
